// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DN404} from "lib/dn404/src/DN404.sol";
import {DN404Mirror} from "lib/dn404/src/DN404Mirror.sol";
import {Ownable} from "lib/dn404/src/example/SimpleDN404.sol";

import {IDescriptor} from "./interfaces/IDescriptor.sol";

contract Shoe404 is DN404, Ownable {
    string private _name;
    string private _symbol;
    IDescriptor private _descriptor;

    constructor(string memory name_, string memory symbol_, uint96 initialTokenSupply, address initialSupplyOwner) {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialSupplyOwner, mirror);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function setDescriptor(IDescriptor descriptor) public onlyOwner {
        _descriptor = descriptor;
    }

    function getDescriptor() public view returns (IDescriptor) {
        return _descriptor;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        result = _descriptor.tokenURI(tokenId);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function withdraw() public onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");

        require(success, "Shoe404: withdraw failed");
    }
}
