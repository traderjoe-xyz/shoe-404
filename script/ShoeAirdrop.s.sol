// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console2 as console} from "forge-std/console2.sol";

import {Script} from "forge-std/Script.sol";
import {Shoe404} from "src/Shoe404.sol";

contract ShoeAirdrop is Script {
    function run() public {
        Shoe404 shoe = new Shoe404("Shoe404", "SHOE", 10_000e18, address(this));

        uint256 gasUsed;

        for (uint256 i = 0; i < 1000; i++) {
            address recipient = address(uint160(uint256(keccak256(abi.encodePacked(i)))));

            uint256 gasBefore = gasleft();
            shoe.transfer(recipient, 1);
            gasUsed += gasBefore - gasleft();
        }

        console.log("Gas used for transfers: %e", gasUsed * 25e9);

        gasUsed = 0;

        for (uint256 i = 0; i < 1000; i++) {
            address recipient = address(uint160(uint256(keccak256(abi.encodePacked(i + 1e18)))));

            uint256 gasBefore = gasleft();
            shoe.transfer(recipient, 1e18);
            gasUsed += gasBefore - gasleft();
        }

        console.log("Gas used for mints: %e", gasUsed * 25e9);
    }
}
