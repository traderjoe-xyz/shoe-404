// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DN404Mirror} from "dn404/src/DN404Mirror.sol";
import {ERC2981} from "openzeppelin/contracts/token/common/ERC2981.sol";

contract Shoe404Mirror is DN404Mirror, ERC2981 {
    /**
     * @dev Thrown when an account that is not authorized to perform an operation tries to perform it
     * @param account The account that is not authorized to perform an operation
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev DN404Mirror is pulling ownership from the DN404 contract, so no need to use the Ownable2Step contract here
     */
    modifier onlyOwner() {
        if (msg.sender != owner()) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }

        _;
    }

    constructor(address deployer) DN404Mirror(deployer) {}

    function supportsInterface(bytes4 interfaceId) public view override(DN404Mirror, ERC2981) returns (bool) {
        return DN404Mirror.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 royaltyFraction) external onlyOwner {
        _setDefaultRoyalty(receiver, royaltyFraction);
    }
}
