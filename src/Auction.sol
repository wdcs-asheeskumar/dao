// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
// import {UUPSUpgradeable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
// import {Ownable2StepUpgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/access/Ownable2StepUpgradeable.sol";
// import "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

contract MyNFTToken is ERC721 {
    constructor() ERC721("MyNFTAuctionToken", "MNFTAT") {}

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}

contract Auction {
    address payable auctioner;
    uint256 auctionTimePeriod;
    uint256 timeForTransferNFT;
    address payable highestBider;
    uint256 highestbid;
    bool public reciptConfirmed;
    bool public NFTReleased;
    bool public fundsReleased;

    mapping(uint256 => bool) public NFTTransferStatus;

    MyNFTToken public myNFTToken;

    constructor(address _myNFTToken) {
        // _disableInitializers();
        myNFTToken = MyNFTToken(_myNFTToken);
    }

    // function initialize(address _myNFTToken) public initializer {
    //     Ownable2StepUpgradeable.__Ownable2Step_init();
    //     myNFTToken = MyNFTToken(_myNFTToken);
    // }

    // function _authorizeUpgrade(
    //     address newImplementation
    // ) internal virtual override onlyOwner {}

    function startAuction() public payable {
        require(
            msg.sender == auctioner,
            "only the auctioner can call this function"
        );
        auctionTimePeriod = block.timestamp + 7 days;
        timeForTransferNFT = block.timestamp + 8 days;
    }

    function bidNFT(uint256 _bid) public payable {
        require(block.timestamp < auctionTimePeriod, "Auction is finished");
        require(
            msg.sender != auctioner || msg.sender != address(0),
            "Auctioner can't participate in biding and address must be valid"
        );
        require(msg.sender.balance >= _bid, "Insufficient balance to bid");
        require(highestbid < _bid, "bid has to be more than the highest bid");
        highestBider.transfer(highestbid);
        payable(address(this)).transfer(_bid);
        highestBider = payable(msg.sender);
        highestbid = _bid;
    }

    function releaseNFT(uint256 _tokenId) public payable {
        require(
            msg.sender == auctioner,
            "only auctioner can operate withdraw function"
        );
        require(
            block.timestamp >= auctionTimePeriod,
            "Auction is still in progress"
        );
        require(
            NFTTransferStatus[_tokenId] == false,
            "NFT has already been transfered"
        );
        NFTReleased = true;
        auctioner.transfer(highestbid);
        myNFTToken.safeMint(highestBider, highestbid);
        NFTTransferStatus[_tokenId] = true;
    }

    function releaseFunds() public payable{
        require(msg.sender == highestBider, "only highest bider can execute this function");
        require(NFTReleased == true, "nft has not been released yet");
        require(reciptConfirmed == false, "recipt already confirmed");
        require(fundsReleased == false, "funds already been released");
        reciptConfirmed = true;
        fundsReleased = true;
        payable(auctioner).transfer(highestbid);
    }

    function refund() public payable {
        require(
            msg.sender == highestBider,
            "only highest bider can operate this function"
        );
        require(
            block.timestamp >= timeForTransferNFT,
            "The time for NFT transfer is still going on"
        );
        highestBider.transfer(highestbid);
    }

    function isAuctionActive() public view returns (bool) {
        if (block.timestamp < auctionTimePeriod) {
            return true;
        } else {
            return false;
        }
    }

    function isTimeForTransferNFT() public view returns (bool) {
        if (block.timestamp < timeForTransferNFT) {
            return true;
        } else {
            return false;
        }
    }

    fallback() external payable {}
    receive() external payable {}
}

