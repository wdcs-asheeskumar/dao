// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20 {
    struct StakingRecord {
        address staker;
        uint256 stakingTime;
        uint256 stakingAmount;
        uint256 stakingReward;
    }

    address public owner;
    uint256 public stakersId;
    mapping(uint256 => StakingRecord) public stakingRecord;
    mapping(uint256 => mapping(address => bool)) public stakersList;

    constructor() ERC20("MyTokenStaking", "MTS") {
        owner = msg.sender;
        _mint(address(this), 10000000 * (10 ** 18));
    }

    function mintTokens(uint256 _tokens) public {
        require(msg.sender == owner, "only owner can mint tokens");
        _mint(address(this), _tokens);
    }

    function tokenStaking(uint256 _stakingAmount) public {
        stakersId = stakersId + 1;
        stakingRecord[stakersId].staker = msg.sender;
        stakingRecord[stakersId].stakingTime = block.timestamp;
        stakingRecord[stakersId].stakingAmount = _stakingAmount;
        _mint(address(this), _stakingAmount);
    }

    function rewardsCalculation(uint256 _stakersId) public returns (uint256) {
        uint256 stakingTime = (block.timestamp -
            stakingRecord[_stakersId].stakingTime) / 30;

        if (stakingTime <= 12) {
            stakingRecord[_stakersId].stakingReward =
                stakingRecord[_stakersId].stakingAmount +
                (stakingRecord[_stakersId].stakingAmount * 5 * stakingTime) /
                100;

            return stakingRecord[_stakersId].stakingReward;
        } else {
            stakingRecord[_stakersId].stakingReward =
                stakingRecord[_stakersId].stakingAmount +
                (stakingRecord[_stakersId].stakingAmount * 60) /
                100;

            return stakingRecord[_stakersId].stakingReward;
        }
    }

    function unstaking(uint256 _stakersId) public {
        uint256 reward = rewardsCalculation(_stakersId);
        stakingRecord[_stakersId].stakingReward = 0;
        transferFrom(address(this), msg.sender, reward);
    }

    function withdrawReward(uint256 _stakersId) public {
        uint256 reward = rewardsCalculation(_stakersId) -
            stakingRecord[_stakersId].stakingAmount;
        stakingRecord[_stakersId].stakingReward = stakingRecord[_stakersId]
            .stakingAmount;
        transferFrom(address(this), msg.sender, reward);
    }
}

// function tokenStaking() -> struct stakingRecord {address, stakingAmount, stakingPeriod, stakingReward}
// function rewardsCalculation()
// function unstaking()
// function withdrawRewards()
