// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DSmartContract is ERC20 {
    struct MemberDetails {
        address memberAddress;
        uint256 memberSince;
        uint256 tokens;
        uint256[] noOfProposalsCreated;
        uint256[] noOfProposalsVoted;
    }

    struct ProposalDetails {
        string proposalDescription;
        uint256 voteCount;
        uint256 timePeriod;
        uint256 tokensForProposal;
        bool executedOrNot;
    }

    uint256 public memberId;
    uint256 public proposalId;

    uint256 public totalTokens;

    uint256 public totalActiveMembers;

    mapping(uint256 => MemberDetails) public memberDetails;
    mapping(uint256 => ProposalDetails) public proposalDetails;

    mapping(uint256 => mapping(address => bool)) public proposalVotingRecord;

    mapping(address => bool) public membersList;

    constructor() ERC20("MyToken", "MTK") {}

    function addMember() public {
        require(
            membersList[msg.sender] == false,
            "member has already been registered"
        );

        memberId = memberId + 1;
        memberDetails[memberId].memberAddress = msg.sender;
        memberDetails[memberId].memberSince = block.timestamp;
        memberDetails[memberId].tokens = 100;
        totalTokens = totalTokens + 100;
        totalActiveMembers = totalActiveMembers + 1;
        membersList[msg.sender] = true;
        _mint(address(this), 100);
    }

    function createProposal(
        string memory _proposalDescription,
        uint256 _timePeriod,
        uint256 _memberId,
        uint256 _tokensForProposal
    ) public {
        require(
            membersList[msg.sender] == true,
            "Only members can create a proposal"
        );
        proposalDetails[proposalId].proposalDescription = _proposalDescription;
        proposalDetails[proposalId].voteCount =
            proposalDetails[proposalId].voteCount +
            1;
        proposalDetails[proposalId].timePeriod =
            block.timestamp +
            _timePeriod *
            1 seconds;
        proposalDetails[proposalId].tokensForProposal = _tokensForProposal;
        proposalDetails[proposalId].executedOrNot = false;
        totalTokens = totalTokens + _tokensForProposal;
        proposalVotingRecord[proposalId][msg.sender] = true;
        memberDetails[memberId].noOfProposalsCreated.push(proposalId);
        memberDetails[_memberId].noOfProposalsVoted.push(proposalId);
        _mint(address(this), _tokensForProposal);
    }

    function removeMember(address _memberAddress) public {
        require(
            membersList[msg.sender] == true,
            "only members can remove someone from the list"
        );
        require(
            membersList[_memberAddress] == true,
            "member doesn't exist or member already removed"
        );

        totalActiveMembers = totalActiveMembers - 1;
        membersList[_memberAddress] = false;
    }

    function voteProposal(uint256 _proposalId) public {
        require(
            membersList[msg.sender] == true,
            "Only the members can vote on the proposal"
        );

        require(
            proposalDetails[_proposalId].executedOrNot == false,
            "proposal has already been executed"
        );

        require(
            block.timestamp <= proposalDetails[_proposalId].timePeriod,
            "proposal has expired"
        );
        require(
            proposalVotingRecord[_proposalId][msg.sender] == false,
            "member has already voted"
        );

        proposalDetails[_proposalId].voteCount =
            proposalDetails[_proposalId].voteCount +
            1;
        proposalVotingRecord[_proposalId][msg.sender] = true;
        memberDetails[memberId].noOfProposalsVoted.push(proposalId);
        _mint(address(this), proposalDetails[_proposalId].tokensForProposal);
    }

    function executeProposal(uint256 _proposalId) public payable {
        require(
            membersList[msg.sender] == true,
            "only members can execute proposal"
        );

        require(
            proposalDetails[_proposalId].voteCount >= totalActiveMembers / 2,
            "proposal does not have enough votes"
        );

        require(
            block.timestamp >= proposalDetails[_proposalId].timePeriod,
            "proposal has not been expired"
        );
        require(
            proposalDetails[_proposalId].executedOrNot == false,
            "proposal already executed"
        );
        proposalDetails[_proposalId].executedOrNot = true;
    }

    function tokensLeft(uint256 _memberId) public view returns (uint256) {
        require(
            msg.sender == memberDetails[_memberId].memberAddress,
            "only member can view there tokens"
        );
        return memberDetails[_memberId].tokens;
    }

    function checkExecutedOrNot(
        uint256 _proposalId
    ) public view returns (bool) {
        return proposalDetails[_proposalId].executedOrNot;
    }
}

// membersData struct -> to store the data of members
// struct to store proposals details
// memberId and proposalId as counters of members and proposals
// total tokens to calculate total number of tokens in the contract
// totalActiveMembers for keeping list of active members
// proposalVotingRecord for keeping record of voting in each proposal
// membersList list of members

// addMembers() -> adding members, only the members which are part of it can add members
// createProposal() -> only members can create a proposal.
// voteProposal() -> members can cast there votes
// executeProposal() -> when the proposal reaches the minimum vote count, it gets executed
