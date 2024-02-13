// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "lib/dn404/src/example/SimpleDN404.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract ShoeDescriptor is Ownable {
    string private _baseURI;

    constructor() {
        _initializeOwner(msg.sender);
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory result) {
        if (bytes(_baseURI).length != 0) {
            uint256 shoeId = uint256(keccak256(abi.encodePacked("SHOE", tokenId))) % 5;

            result = string(abi.encodePacked(_baseURI, Strings.toString(shoeId)));
        }
    }
}
