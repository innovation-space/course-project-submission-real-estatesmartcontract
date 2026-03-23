// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RealEstate - Property listing with price update
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

    event PropertyListed(uint256 indexed propertyId, address indexed owner, uint256 price);
    event PropertyPriceUpdated(uint256 indexed propertyId, uint256 newPrice);

    function listProperty(string calldata _location, uint256 _priceWei) external returns (uint256) {
        require(_priceWei > 0, "Price must be > 0");
        propertyCount++;
        uint256 id = propertyCount;
        properties[id] = Property(id, msg.sender, _location, _priceWei, PropertyStatus.Available, true);
        emit PropertyListed(id, msg.sender, _priceWei);
        return id;
    }

    /// @notice Owner can update asking price while property is available
    function updatePrice(uint256 _propertyId, uint256 _newPrice) external {
        require(properties[_propertyId].exists, "Property does not exist");
        require(msg.sender == properties[_propertyId].owner, "Not property owner");
        require(properties[_propertyId].status == PropertyStatus.Available, "Not available");
        properties[_propertyId].priceWei = _newPrice;
        emit PropertyPriceUpdated(_propertyId, _newPrice);
    }

    function getProperty(uint256 _id) external view returns (Property memory) {
        require(properties[_id].exists, "Property does not exist");
        return properties[_id];
    }
}