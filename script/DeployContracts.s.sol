// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/src/Script.sol";
import {Shoe404, IDescriptor} from "src/Shoe404.sol";
import {Shoe404Mirror} from "src/Shoe404Mirror.sol";
import {ShoeDescriptor} from "src/ShoeDescriptor.sol";

contract ShoeContractDeployment is Script {
    address constant ROYALTY_RECEIVER = 0x3DF701bFf974aFaE3F5A213fd52D3400f9D764c9;
    uint96 constant ROYALTY_BPS = 50; // 0,5%

    function run() public returns (Shoe404 shoe, Shoe404Mirror mirror, ShoeDescriptor descriptor) {
        string memory rpc = vm.envString("RPC_URL");
        address deployer = vm.rememberKey(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        address airdropManager = vm.rememberKey(vm.envUint("AIRDROP_PRIVATE_KEY"));

        vm.createSelectFork(rpc);

        vm.startBroadcast(deployer);
        shoe = new Shoe404("Shoe404", "SHOE", 19_404e18, airdropManager);
        descriptor = new ShoeDescriptor(airdropManager);
        mirror = Shoe404Mirror(payable(shoe.mirrorERC721()));
        vm.stopBroadcast();

        vm.startBroadcast(airdropManager);
        mirror.pullOwner();
        descriptor.setBaseURI("ipfs://bafybeigjspcbw3c5lvunbotpu35bwozeujzxpju4kd45tbe7zyzq5d2ime/");
        shoe.setDescriptor(IDescriptor(address(descriptor)));
        mirror.setDefaultRoyalty(ROYALTY_RECEIVER, ROYALTY_BPS);
    }
}
