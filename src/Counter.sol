// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UUPSUpgradeable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Ownable2StepUpgradeable} from "../lib/openzeppelin-contracts-upgradeable/contracts/access/Ownable2StepUpgradeable.sol";
import "../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

contract Counter is UUPSUpgradeable, Ownable2StepUpgradeable {
    uint256 public number;
    uint256 public salt;
    uint256[] public keys;
    address public random;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _random, uint256 _salt, uint256[2] memory _randomKeys) public initializer {
        Ownable2StepUpgradeable.__Ownable2Step_init();
        salt = _salt;
        random = _random;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyOwner {}

    function setNumber(uint256 newNumber) public {
        number = salt + newNumber;
    }

    function increment() public {
        number++;
    }
}
