// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RealEstate - Initial scaffold
/// @notice Basic property struct and listing registry
contract RealEstate {

    enum PropertyStatus { Available, UnderEscrow, Sold, Rented }

    struct Property {
        uint256 id;
        address owner;
        string location;
        uint256 priceWei;
        PropertyStatus status;
        bool exists;
    }

    uint256 public propertyCount;
    mapping(uint256 => Property) public properties;
}
