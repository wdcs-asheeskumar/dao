// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MyNFTToken is ERC721 {
    constructor() ERC721("MyNFTAuctionToken", "MNFTAT") {}

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}

contract Auction {
    uint256 auctionId;

    struct AuctionRecord {
        address payable auctioner;
        uint256 auctionId;
        uint256 auctionTimePeriod;
        uint256 timeForTransferNFT;
        address payable highestBider;
        uint256 highestbid;
        bool reciptConfirmed;
        bool NFTReleased;
        bool fundsReleased;
    }

    mapping(uint256 => bool) NFTTransferStatus;
    mapping(uint256 => AuctionRecord) auctionRecord;

    MyNFTToken public myNFTToken;

    constructor(address _myNFTToken) {
        myNFTToken = MyNFTToken(_myNFTToken);
        // auctioner = payable(msg.sender);
    }

    function startAuction(
        uint256 _auctionTimePeriod,
        uint256 _timeForTransferNFT
    ) public {
        auctionRecord[auctionId].auctionId = auctionId;
        auctionRecord[auctionId].auctioner = payable(msg.sender);
        auctionRecord[auctionId].auctionTimePeriod =
            block.timestamp +
            _auctionTimePeriod *
            1 seconds;
        auctionRecord[auctionId].timeForTransferNFT =
            block.timestamp +
            _timeForTransferNFT *
            1 seconds;

        auctionId++;
    }

    function bidNFT(uint256 _bid, uint256 _auctionId) public payable {
        require(
            block.timestamp < auctionRecord[_auctionId].auctionTimePeriod,
            "Auction is finished"
        );
        require(
            msg.sender != auctionRecord[_auctionId].auctioner ||
                msg.sender != address(0),
            "Auctioner can't participate in biding and address must be valid"
        );
        require(msg.sender.balance >= _bid, "Insufficient balance to bid");
        require(
            auctionRecord[_auctionId].highestbid < _bid,
            "bid has to be more than the highest bid"
        );

        auctionRecord[_auctionId].highestBider.transfer(
            auctionRecord[_auctionId].highestbid
        );

        payable(address(this)).transfer(_bid);
        auctionRecord[_auctionId].highestBider = payable(msg.sender);
        auctionRecord[_auctionId].highestbid = _bid;
    }

    function releaseNFT(uint256 _tokenId, uint256 _auctionId) public {
        require(
            msg.sender == auctionRecord[_auctionId].auctioner,
            "only auctioner can operate withdraw function"
        );
        require(
            block.timestamp >= auctionRecord[_auctionId].auctionTimePeriod,
            "Auction is still in progress"
        );
        require(
            NFTTransferStatus[_tokenId] == false,
            "NFT has already been transfered"
        );
        auctionRecord[_auctionId].NFTReleased = true;
        myNFTToken.safeMint(
            auctionRecord[_auctionId].highestBider,
            auctionRecord[_auctionId].highestbid
        );
        NFTTransferStatus[_tokenId] = true;
    }

    function releaseFunds(uint256 _auctionId) public payable {
        require(
            msg.sender == auctionRecord[_auctionId].highestBider,
            "only highest bider can execute this function"
        );
        require(
            auctionRecord[_auctionId].NFTReleased == true,
            "nft has not been released yet"
        );
        require(
            auctionRecord[_auctionId].reciptConfirmed == false,
            "recipt already confirmed"
        );
        require(
            auctionRecord[_auctionId].fundsReleased == false,
            "funds already been released"
        );
        auctionRecord[_auctionId].reciptConfirmed = true;
        auctionRecord[_auctionId].fundsReleased = true;
        payable(auctionRecord[_auctionId].auctioner).transfer(
            auctionRecord[_auctionId].highestbid
        );
    }

    function refund(uint256 _auctionId) public {
        require(
            msg.sender == auctionRecord[_auctionId].highestBider,
            "only highest bider can operate this function"
        );
        require(
            block.timestamp >= auctionRecord[_auctionId].timeForTransferNFT,
            "The time for NFT transfer is still going on"
        );
        payable(auctionRecord[_auctionId].highestBider).transfer(
            auctionRecord[_auctionId].highestbid
        );
    }

    function isAuctionActive(uint256 _auctionId) public view returns (bool) {
        if (block.timestamp < auctionRecord[_auctionId].auctionTimePeriod) {
            return true;
        } else {
            return false;
        }
    }

    function isTimeForTransferNFT(
        uint256 _auctionId
    ) public view returns (bool) {
        if (block.timestamp < auctionRecord[_auctionId].timeForTransferNFT) {
            return true;
        } else {
            return false;
        }
    }

    fallback() external payable {}

    receive() external payable {}
}
