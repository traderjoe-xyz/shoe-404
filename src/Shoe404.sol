// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DN404} from "dn404/src/DN404.sol";
import {DN404Mirror} from "dn404/src/DN404Mirror.sol";
import {Ownable2Step, Ownable} from "openzeppelin/contracts/access/Ownable2Step.sol";

import {IDescriptor} from "./interfaces/IDescriptor.sol";

contract Shoe404 is DN404, Ownable2Step {
    /**
     * @dev Name of the token
     */
    string private _name;

    /**
     * @dev Symbol of the token
     */
    string private _symbol;

    /**
     * @dev Descriptor contract
     */
    IDescriptor private _descriptor;

    /**
     * @dev Thrown when an invalid input is provided
     */
    error InvalidInput();

    /**
     * @dev Thrown if the fund transfer fails
     */
    error WithdrawalFailed();

    /**
     * @dev Emitted when the descriptor contract is changed
     * @param descriptor Descriptor contract
     */
    event DescriptorChanged(address indexed descriptor);

    /**
     * @dev Emitted when the contract owner withdraws the contract balance
     * @param amount Amount withdrawn
     */
    event Withdrawn(uint256 amount);

    constructor(string memory name_, string memory symbol_, uint96 initialTokenSupply, address initialOwner)
        Ownable(initialOwner)
    {
        _name = name_;
        _symbol = symbol_;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialOwner, mirror);
    }

    /**
     * @notice Name of the token
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @notice Symbol of the token
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Token URI
     * @param tokenId Token ID
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        result = _descriptor.tokenURI(tokenId);
    }

    /**
     * @notice Descriptor contract
     */
    function getDescriptor() external view returns (IDescriptor) {
        return _descriptor;
    }

    /**
     * @notice Airdrops tokens from the owner wallet to a list of recipients
     * @param recipients List of recipients
     * @param amounts List of amounts
     */
    function airdrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        if (recipients.length != amounts.length) {
            revert InvalidInput();
        }

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    /**
     * @notice Withdraws the contract balance
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        (bool success,) = payable(msg.sender).call{value: balance}("");

        if (!success) {
            revert WithdrawalFailed();
        }

        emit Withdrawn(balance);
    }

    /**
     * @notice Sets the descriptor contract
     * @param descriptor Descriptor contract
     */
    function setDescriptor(IDescriptor descriptor) external onlyOwner {
        _descriptor = descriptor;

        emit DescriptorChanged(address(descriptor));
    }
}
