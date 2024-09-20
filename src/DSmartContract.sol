// SPDX-License-Identifier:MIT

pragma solidity 0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DSmartContract is ERC20 {
    struct MemberDetails {
        address memberAddress;
        uint256 tokensLocked;
        uint256[] noOfProposalsCreated;
        uint256[] noOfProposalsVoted;
    }

    struct ProposalDetails {
        string proposalDescription;
        uint256 voteCount;
        uint256 timePeriod;
        uint256 tokensForProposal;
        uint256[] listOfMembersId;
        bool executedOrNot;
        string reasonToChallenge;
        uint256 challengedVotes;
    }

    uint256 public memberId;
    uint256 public proposalId;

    uint256 public totalTokens;

    uint256 public totalActiveMembers;

    mapping(uint256 => MemberDetails) public memberDetails;
    mapping(uint256 => ProposalDetails) public proposalDetails;

    mapping(uint256 => mapping(address => bool)) public proposalVotingRecord;

    mapping(uint256 => bool) public proposalsList;
    mapping(address => bool) public membersList;

    constructor() ERC20("MyToken", "MTK") {}

    function addMember() public {
        require(
            membersList[msg.sender] == false,
            "member has already been registered"
        );

        memberId = memberId + 1;
        memberDetails[memberId].memberAddress = msg.sender;
        memberDetails[memberId].tokensLocked = 100;
        totalTokens = totalTokens + 100;
        totalActiveMembers = totalActiveMembers + 1;
        membersList[msg.sender] = true;
        _mint(address(this), 100);
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
        require(
            proposalsList[proposalId] == false,
            "Proposal already registered"
        );

        proposalId = proposalId + 1;
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

        proposalDetails[proposalId].listOfMembersId.push(_memberId);

        totalTokens = totalTokens + _tokensForProposal;

        proposalVotingRecord[proposalId][msg.sender] = true;

        memberDetails[_memberId].noOfProposalsCreated.push(proposalId);

        memberDetails[_memberId].noOfProposalsVoted.push(proposalId);

        proposalsList[proposalId] = true;

        _mint(address(this), _tokensForProposal);
    }


    function voteProposal(uint256 _proposalId, uint256 _memberId) public {
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
        proposalDetails[_proposalId].listOfMembersId.push(_memberId);
        proposalVotingRecord[_proposalId][msg.sender] = true;
        
        memberDetails[_memberId].noOfProposalsVoted.push(proposalId);
        memberDetails[_memberId].tokensLocked =
            memberDetails[_memberId].tokensLocked +
            proposalDetails[_proposalId].tokensForProposal;
        _mint(address(this), proposalDetails[_proposalId].tokensForProposal);
    }

    function executeProposal(uint256 _proposalId) public {
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

    function challengingProposal(
        string memory _reasonToChallenge,
        uint256 _proposalId
    ) public {
        require(
            membersList[msg.sender] == true,
            "only members can challenge the proposal"
        );

        require(
            proposalDetails[_proposalId].executedOrNot == true,
            "proposal still not executed"
        );

        proposalDetails[_proposalId].reasonToChallenge = _reasonToChallenge;
        proposalDetails[_proposalId].challengedVotes =
            proposalDetails[_proposalId].challengedVotes +
            1;

        if (
            proposalDetails[_proposalId].challengedVotes >
            totalActiveMembers / 2
        ) {
            revokeExecution(_proposalId);
        }
    }

    function revokeExecution(uint256 _proposalId) internal {
        proposalDetails[_proposalId].executedOrNot = false;

        for (
            uint256 i = 0;
            i < proposalDetails[_proposalId].listOfMembersId.length;
            i++
        ) {
            memberDetails[proposalDetails[_proposalId].listOfMembersId[i]]
                .tokensLocked =
                memberDetails[proposalDetails[_proposalId].listOfMembersId[i]]
                    .tokensLocked -
                proposalDetails[_proposalId].tokensForProposal;

            transferFrom(
                address(this),
                memberDetails[proposalDetails[_proposalId].listOfMembersId[i]]
                    .memberAddress,
                proposalDetails[_proposalId].tokensForProposal
            );
        }
    }

    function tokensStaked(uint256 _memberId) public view returns (uint256) {
        require(
            msg.sender == memberDetails[_memberId].memberAddress,
            "only member can view there tokens"
        );
        return memberDetails[_memberId].tokensLocked;
    }

    function checkExecutedOrNot(
        uint256 _proposalId
    ) public view returns (bool) {
        return proposalDetails[_proposalId].executedOrNot;
    }

    function isMember(address _member) public view returns (bool) {
        return membersList[_member];
    }

    function isProposal(uint256 _proposalId) public view returns (bool) {
        return proposalsList[_proposalId];
    }

    function memberHasVotedOrNot(
        uint256 _proposalId,
        address memberAddr
    ) public view returns (bool) {
        return proposalVotingRecord[_proposalId][memberAddr];
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
