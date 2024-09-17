// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Counter} from "src/Counter.sol";

contract NewContract {
    uint256 public number;
    Counter public counter;

    constructor(address _counterAddress) {
        counter = Counter(_counterAddress);
    }

    function setNewValue(uint256 _newValue) public {
        number = counter.number() + _newValue;
    }
}
