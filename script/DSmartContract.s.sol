// SPDX-License-Identifier:MIT

pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {DSmartContract} from "../src/DSmartContract.sol";

contract DSmartContractScript is Script {
    DSmartContract public dSmartContract;

    function run() public {
        vm.startBroadcast();
        dSmartContract = new DSmartContract();
        vm.stopBroadcast();
    }
}
