// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2 as console} from "forge-std/src/console2.sol";

import {Script} from "forge-std/src/Script.sol";
import {Shoe404} from "src/Shoe404.sol";

contract ShoeAirdrop is Script {
    function run() public {
        Shoe404 shoe = new Shoe404("Shoe404", "SHOE", 10_000e18, address(this));

        address[] memory recipients = new address[](1000);
        uint256[] memory amounts = new uint256[](1000);

        for (uint256 i = 0; i < 1000; i++) {
            recipients[i] = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
            amounts[i] = 1;
        }

        uint256 gasBefore = gasleft();
        shoe.airdrop(recipients, amounts);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("Gas used for transfers: %e", gasUsed * 25e9);

        gasUsed = 0;

        for (uint256 i = 0; i < 1000; i++) {
            recipients[i] = address(uint160(uint256(keccak256(abi.encodePacked(type(uint256).max - i)))));
            amounts[i] = 1e18;
        }

        gasBefore = gasleft();
        shoe.airdrop(recipients, amounts);
        gasUsed = gasBefore - gasleft();

        if (gasUsed > 14e6) {
            console.log("Gas used higher than block size limit !");
        }

        console.log("Gas used for mints: %e", gasUsed * 25e9);
    }
}
