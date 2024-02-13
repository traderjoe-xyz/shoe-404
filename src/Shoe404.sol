// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DN404} from "lib/dn404/src/DN404.sol";
import {DN404Mirror} from "lib/dn404/src/DN404Mirror.sol";
import {Ownable2Step, Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";

import {IDescriptor} from "./interfaces/IDescriptor.sol";

contract Shoe404 is DN404, Ownable2Step {
    string private _name;
    string private _symbol;
    IDescriptor private _descriptor;

    event DescriptorChanged(address indexed descriptor);

    event Withdrawn(uint256 amount);

    constructor(string memory name_, string memory symbol_, uint96 initialTokenSupply, address initialSupplyOwner)
        Ownable(msg.sender)
    {
        _name = name_;
        _symbol = symbol_;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialSupplyOwner, mirror);
    }

    function airdrop(address[] calldata recipients, uint256[] calldata amounts) public onlyOwner {
        require(recipients.length == amounts.length, "Shoe404: invalid input");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function setDescriptor(IDescriptor descriptor) public onlyOwner {
        _descriptor = descriptor;

        emit DescriptorChanged(address(descriptor));
    }

    function getDescriptor() public view returns (IDescriptor) {
        return _descriptor;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        result = _descriptor.tokenURI(tokenId);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success,) = payable(msg.sender).call{value: balance}("");

        require(success, "Shoe404: withdraw failed");

        emit Withdrawn(balance);
    }

    function setSkipNFT(bool skipNFT) public override onlyOwner {
        super.setSkipNFT(skipNFT);
    }
}
