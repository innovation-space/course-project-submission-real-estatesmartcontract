// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    // Contract skeleton for property registration

    struct Property {
        uint id;
        string name;
        address owner;
    }

    mapping(uint => Property) public properties;

    event PropertyRegistered(uint id, string name, address owner);

    function registerProperty(uint _id, string memory _name) public {
        // Logic will be added later
    }
}
