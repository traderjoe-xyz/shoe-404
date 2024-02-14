// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/src/Test.sol";
import {Shoe404, Shoe404Mirror, DN404} from "src/Shoe404.sol";
import {ShoeDescriptor} from "src/ShoeDescriptor.sol";
import {IDescriptor} from "src/interfaces/IDescriptor.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract Shoe404Test is Test {
    Shoe404 shoe;
    ShoeDescriptor descriptor;
    Shoe404Mirror shoeMirror;

    function setUp() public virtual {
        shoe = new Shoe404("Shoe404", "SHOE", 10e18, address(this));
        shoeMirror = Shoe404Mirror(payable(shoe.mirrorERC721()));

        descriptor = new ShoeDescriptor();
        shoe.setDescriptor(IDescriptor(address(descriptor)));
    }

    function test_Initialization() public {
        assertEq(shoe.name(), "Shoe404", "test_Initilization::1");
        assertEq(shoe.symbol(), "SHOE", "test_Initilization::2");
        assertEq(shoe.totalSupply(), 10e18, "test_Initilization::3");
        assertEq(shoe.balanceOf(address(this)), 10e18, "test_Initilization::4");
    }

    function test_AirdropNFTs() public {
        address[] memory recipients = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            recipients[i] = _generateRandomRecipient();
        }

        shoe.airdrop(recipients, 1e18);

        for (uint256 i = 0; i < 5; i++) {
            assertEq(shoe.balanceOf(recipients[i]), 1e18, "test_AirdropNFTs::1");
            assertEq(shoeMirror.ownerOf(i + 1), recipients[i], "test_AirdropNFTs::2");
        }

        assertEq(shoe.balanceOf(address(this)), 5e18, "test_AirdropNFTs::3");
    }

    function test_AirdropTokens() public {
        address[] memory recipients = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            recipients[i] = _generateRandomRecipient();
        }

        shoe.airdrop(recipients, 0.5e18);

        for (uint256 i = 0; i < 5; i++) {
            assertEq(shoe.balanceOf(recipients[i]), 0.5e18, "test_AirdropTokens::1");

            vm.expectRevert(DN404.TokenDoesNotExist.selector);
            assertEq(shoeMirror.ownerOf(i + 1), address(0), "test_AirdropTokens::2");
        }

        assertEq(shoe.balanceOf(address(this)), 7.5e18, "test_AirdropTokens::3");
    }

    function test_TransferOwnership() public {
        address newOwner = _generateRandomRecipient();

        shoe.transferOwnership(newOwner);

        vm.prank(newOwner);
        shoe.acceptOwnership();

        assertEq(shoe.owner(), newOwner, "test_TransferOwnership::1");
    }

    function test_TokenURI() public {
        assertEq(address(shoe.getDescriptor()), address(descriptor), "test_TokenURI::1");

        string memory baseURI = "https://shoe404.com/";
        descriptor.setBaseURI(baseURI);

        assertEq(descriptor.baseURI(), baseURI, "test_TokenURI::2");
        assertEq(shoe.tokenURI(1), string(abi.encodePacked(baseURI, "3")), "test_TokenURI::3");
        assertEq(shoe.tokenURI(14), string(abi.encodePacked(baseURI, "0")), "test_TokenURI::4");

        descriptor.setBaseURI("");
        assertEq(shoe.tokenURI(1), "", "test_TokenURI::5");

        descriptor = new ShoeDescriptor();
        descriptor.setBaseURI(baseURI);

        shoe.setDescriptor(IDescriptor(address(descriptor)));

        assertEq(shoe.tokenURI(1), string(abi.encodePacked(baseURI, "3")), "test_TokenURI::6");
    }

    receive() external payable {}

    uint256 nonce = 0;

    function _generateRandomRecipient() internal returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(nonce++)))));
    }
}
