// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {NewContract} from "../src/NewContract.sol";
import {MyToken} from "../src/MyToken.sol";
import {ERC1967Proxy} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "../lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";

contract CounterScript is Script {
    Counter public counter;
    NewContract public newContract;
    MyToken public myToken;
    address public proxyAddress;
    bytes public data;

    address public random = 0xcF5D3555140A75E9b9a1ED56D1dB9E95064BA4D5;
    uint256 public salt = 2;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        uint256[] memory randomkey = vm.envUint("RANDOM_KEYS", ",");
        uint256[2] memory randomKeys_1 = [randomkey[0], randomkey[1]];
        console.logUint(randomKeys_1[0]);
        console.logUint(randomKeys_1[1]);
        counter = new Counter();
        newContract = new NewContract(address(counter));
        myToken = new MyToken();
        data = abi.encodeCall(
            counter.initialize,
            (address(random), salt, randomKeys_1)
        );
        proxyAddress = address(new ERC1967Proxy(address(counter), data));
        console.logBytes(data);
        vm.stopBroadcast();
    }
}
