// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable2Step, Ownable} from "openzeppelin/contracts/access/Ownable2Step.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

contract ShoeDescriptor is Ownable2Step {
    /**
     * @dev Number of different shoes
     */
    uint256 private constant _SHOE_COUNT = 5;

    /**
     * @dev Base URI address for the token
     */
    string private _baseURI;

    /**
     * @dev Emitted when the base URI is changed
     * @param baseURI New base URI
     */
    event BaseURIChanged(string baseURI);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Base URI for the token
     */
    function baseURI() public view returns (string memory) {
        return _baseURI;
    }

    /**
     * @notice Token URI. Each token gets a random shoe image between the 5 existing ones
     * @param tokenId Token ID
     */
    function tokenURI(uint256 tokenId) public view returns (string memory result) {
        if (bytes(_baseURI).length != 0) {
            uint256 shoeId = uint256(keccak256(abi.encodePacked("SHOE", tokenId))) % _SHOE_COUNT;

            result = string(abi.encodePacked(_baseURI, Strings.toString(shoeId)));
        }
    }

    /**
     * @notice Set the base URI
     * @param baseURI_ New base URI
     */
    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;

        emit BaseURIChanged(baseURI_);
    }
}
