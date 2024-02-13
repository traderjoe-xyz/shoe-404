// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable2Step, Ownable} from "openzeppelin/contracts/access/Ownable2Step.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract ShoeDescriptor is Ownable2Step {
    string private _baseURI;

    event BaseURIChanged(string baseURI);

    constructor() Ownable(msg.sender) {}

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;

        emit BaseURIChanged(baseURI_);
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
