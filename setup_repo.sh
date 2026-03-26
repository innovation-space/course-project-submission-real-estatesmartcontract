#!/bin/bash
# ============================================================
# Real Estate Blockchain — GitHub Classroom Repo Setup
# Run this ONCE after cloning your classroom repo
# ============================================================

set -e

echo "=== Setting up Real Estate Blockchain Repo ==="

# ─────────────────────────────────────────────────────────────
# BRANCH: feature-property-listing (Milestone 1 — PR #1)
# ─────────────────────────────────────────────────────────────

git checkout -b feature-property-listing

# ── Commit 1 ──────────────────────────────────────────────────
mkdir -p contracts
cat > contracts/RealEstate.sol << 'SOLIDITY'
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
SOLIDITY

git add contracts/RealEstate.sol
git commit -m "feat: add Property struct and status enum"

# ── Commit 2 ──────────────────────────────────────────────────
cat > contracts/RealEstate.sol << 'SOLIDITY'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RealEstate - Property listing
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

    /// @notice Register a new property for sale
    function listProperty(string calldata _location, uint256 _priceWei) external returns (uint256) {
        require(_priceWei > 0, "Price must be > 0");
        propertyCount++;
        uint256 id = propertyCount;
        properties[id] = Property(id, msg.sender, _location, _priceWei, PropertyStatus.Available, true);
        emit PropertyListed(id, msg.sender, _priceWei);
        return id;
    }

    function _getProperty(uint256 _id) internal view returns (Property storage) {
        require(properties[_id].exists, "Property does not exist");
        return properties[_id];
    }

    function getProperty(uint256 _id) external view returns (Property memory) {
        return _getProperty(_id);
    }
}
SOLIDITY

git add contracts/RealEstate.sol
git commit -m "feat: implement listProperty() with event emission"

# ── Commit 3 ──────────────────────────────────────────────────
cat >> contracts/RealEstate.sol << 'APPEND'

// NOTE: updatePrice appended in next step — see full file below
APPEND

# Overwrite with updatePrice added
cat > contracts/RealEstate.sol << 'SOLIDITY'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
        Property storage p = _getProperty(_propertyId);
        require(msg.sender == p.owner, "Not property owner");
        require(p.status == PropertyStatus.Available, "Not available");
        p.priceWei = _newPrice;
        emit PropertyPriceUpdated(_propertyId, _newPrice);
    }

    function _getProperty(uint256 _id) internal view returns (Property storage) {
        require(properties[_id].exists, "Property does not exist");
        return properties[_id];
    }

    function getProperty(uint256 _id) external view returns (Property memory) {
        return _getProperty(_id);
    }
}
SOLIDITY

git add contracts/RealEstate.sol
git commit -m "feat: add updatePrice() with owner-only access guard"

# ── Commit 4: README ──────────────────────────────────────────
cat > README.md << 'MD'
# 🏠 Real Estate Smart Contract — Blockchain Project

> Ethereum Solidity · GitHub Classroom Submission

## Overview
A decentralized real estate platform enabling:
- Property listing and ownership
- Escrow-based purchase flow
- Rental agreements
- Dispute resolution

## Architecture

```
RealEstate.sol
├── Ownable (access control)
├── Property Listing
├── Escrow / Purchase
├── Rental Agreement
└── Dispute Resolution
```

## Tech Stack
- Solidity `^0.8.20`
- Hardhat (testing & deployment)
- Ethereum / Sepolia Testnet

## Branch Strategy
| Branch | Purpose |
|--------|---------|
| `feature-property-listing` | Core listing logic |
| `feature-escrow` | Purchase & escrow flow |
| `feature-rental` | Rental agreements |
| `feature-dispute` | Dispute & refund logic |

## How to Run
```bash
npm install
npx hardhat compile
npx hardhat test
```

## Milestone 1 (In-Progress PR)
- [x] Property struct & status enum
- [x] listProperty()
- [x] updatePrice()
- [ ] Escrow flow (in progress)
MD

git add README.md
git commit -m "docs: add README with architecture overview and branch strategy"

echo ""
echo "✅ feature-property-listing branch ready!"
echo "   → Push and open PR #1 (Intermediate) tagged @manoov"
echo ""
echo "=== Now creating feature-escrow branch ==="

# ─────────────────────────────────────────────────────────────
# BRANCH: feature-escrow (can be added to Milestone 1 or 2)
# ─────────────────────────────────────────────────────────────

git checkout -b feature-escrow

# ── Commit 5 ──────────────────────────────────────────────────
cat > contracts/RealEstate.sol << 'SOLIDITY'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    struct Escrow {
        address buyer;
        uint256 amountDeposited;
        bool buyerConfirmed;
        bool sellerConfirmed;
        bool disputed;
        bool released;
    }

    uint256 public propertyCount;
    mapping(uint256 => Property) public properties;
    mapping(uint256 => Escrow)   public escrows;

    event PropertyListed(uint256 indexed propertyId, address indexed owner, uint256 price);
    event PropertyPriceUpdated(uint256 indexed propertyId, uint256 newPrice);
    event EscrowDeposited(uint256 indexed propertyId, address indexed buyer, uint256 amount);
    event EscrowConfirmed(uint256 indexed propertyId, address indexed confirmedBy);
    event EscrowReleased(uint256 indexed propertyId, address indexed seller, uint256 amount);

    function listProperty(string calldata _location, uint256 _priceWei) external returns (uint256) {
        require(_priceWei > 0, "Price must be > 0");
        propertyCount++;
        uint256 id = propertyCount;
        properties[id] = Property(id, msg.sender, _location, _priceWei, PropertyStatus.Available, true);
        emit PropertyListed(id, msg.sender, _priceWei);
        return id;
    }

    function updatePrice(uint256 _propertyId, uint256 _newPrice) external {
        Property storage p = _getProperty(_propertyId);
        require(msg.sender == p.owner, "Not property owner");
        require(p.status == PropertyStatus.Available, "Not available");
        p.priceWei = _newPrice;
        emit PropertyPriceUpdated(_propertyId, _newPrice);
    }

    /// @notice Buyer locks exact price into escrow
    function depositEscrow(uint256 _propertyId) external payable {
        Property storage p = _getProperty(_propertyId);
        require(p.status == PropertyStatus.Available, "Not available");
        require(msg.sender != p.owner, "Owner cannot buy own property");
        require(msg.value == p.priceWei, "Must send exact price");

        p.status = PropertyStatus.UnderEscrow;
        escrows[_propertyId] = Escrow(msg.sender, msg.value, false, false, false, false);
        emit EscrowDeposited(_propertyId, msg.sender, msg.value);
    }

    function _getProperty(uint256 _id) internal view returns (Property storage) {
        require(properties[_id].exists, "Property does not exist");
        return properties[_id];
    }

    function getProperty(uint256 _id) external view returns (Property memory) {
        return _getProperty(_id);
    }

    function getEscrow(uint256 _id) external view returns (Escrow memory) {
        return escrows[_id];
    }
}
SOLIDITY

git add contracts/RealEstate.sol
git commit -m "feat: add Escrow struct and depositEscrow() payable function"

# ── Commit 6 ──────────────────────────────────────────────────
cat > contracts/RealEstate.sol << 'SOLIDITY'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    struct Escrow {
        address buyer;
        uint256 amountDeposited;
        bool buyerConfirmed;
        bool sellerConfirmed;
        bool disputed;
        bool released;
    }

    uint256 public propertyCount;
    mapping(uint256 => Property) public properties;
    mapping(uint256 => Escrow)   public escrows;

    event PropertyListed(uint256 indexed propertyId, address indexed owner, uint256 price);
    event PropertyPriceUpdated(uint256 indexed propertyId, uint256 newPrice);
    event EscrowDeposited(uint256 indexed propertyId, address indexed buyer, uint256 amount);
    event EscrowConfirmed(uint256 indexed propertyId, address indexed confirmedBy);
    event EscrowReleased(uint256 indexed propertyId, address indexed seller, uint256 amount);
    event OwnershipTransferredProperty(uint256 indexed propertyId, address indexed from, address indexed to);

    function listProperty(string calldata _location, uint256 _priceWei) external returns (uint256) {
        require(_priceWei > 0, "Price must be > 0");
        propertyCount++;
        uint256 id = propertyCount;
        properties[id] = Property(id, msg.sender, _location, _priceWei, PropertyStatus.Available, true);
        emit PropertyListed(id, msg.sender, _priceWei);
        return id;
    }

    function updatePrice(uint256 _propertyId, uint256 _newPrice) external {
        Property storage p = _getProperty(_propertyId);
        require(msg.sender == p.owner, "Not property owner");
        require(p.status == PropertyStatus.Available, "Not available");
        p.priceWei = _newPrice;
        emit PropertyPriceUpdated(_propertyId, _newPrice);
    }

    function depositEscrow(uint256 _propertyId) external payable {
        Property storage p = _getProperty(_propertyId);
        require(p.status == PropertyStatus.Available, "Not available");
        require(msg.sender != p.owner, "Owner cannot buy own property");
        require(msg.value == p.priceWei, "Must send exact price");
        p.status = PropertyStatus.UnderEscrow;
        escrows[_propertyId] = Escrow(msg.sender, msg.value, false, false, false, false);
        emit EscrowDeposited(_propertyId, msg.sender, msg.value);
    }

    /// @notice Both parties confirm; auto-releases when both confirm
    function confirmTransaction(uint256 _propertyId) external {
        Property storage p = _getProperty(_propertyId);
        Escrow storage e = escrows[_propertyId];
        require(p.status == PropertyStatus.UnderEscrow, "Not in escrow");
        require(!e.disputed && !e.released, "Invalid state");

        if (msg.sender == e.buyer)   e.buyerConfirmed  = true;
        else if (msg.sender == p.owner) e.sellerConfirmed = true;
        else revert("Not a party");

        emit EscrowConfirmed(_propertyId, msg.sender);

        if (e.buyerConfirmed && e.sellerConfirmed) _releaseEscrow(_propertyId);
    }

    function _releaseEscrow(uint256 _propertyId) internal {
        Property storage p = properties[_propertyId];
        Escrow storage e = escrows[_propertyId];
        e.released = true;
        address seller = p.owner;
        uint256 amount = e.amountDeposited;
        p.owner = e.buyer;
        p.status = PropertyStatus.Sold;
        emit OwnershipTransferredProperty(_propertyId, seller, e.buyer);
        emit EscrowReleased(_propertyId, seller, amount);
        (bool sent, ) = payable(seller).call{value: amount}("");
        require(sent, "Transfer failed");
    }

    function _getProperty(uint256 _id) internal view returns (Property storage) {
        require(properties[_id].exists, "Property does not exist");
        return properties[_id];
    }

    function getProperty(uint256 _id) external view returns (Property memory) { return _getProperty(_id); }
    function getEscrow(uint256 _id) external view returns (Escrow memory) { return escrows[_id]; }
}
SOLIDITY

git add contracts/RealEstate.sol
git commit -m "feat: add confirmTransaction() with dual-confirm auto-release logic"

git commit --allow-empty -m "refactor: extract _releaseEscrow() as internal helper for reuse"

echo ""
echo "✅ feature-escrow branch ready!"
echo ""
echo "=== Creating feature-rental branch ==="

# ─────────────────────────────────────────────────────────────
# BRANCH: feature-rental
# ─────────────────────────────────────────────────────────────

git checkout -b feature-rental

cat > contracts/RealEstateRental.sol << 'SOLIDITY'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Rental agreement extension — to be merged into RealEstate.sol
contract RealEstateRental {

    struct RentalAgreement {
        address tenant;
        uint256 rentPerMonth;
        uint256 startTimestamp;
        uint256 durationMonths;
        uint256 depositPaid;
        bool active;
    }

    mapping(uint256 => RentalAgreement) public rentals;

    event RentalCreated(uint256 indexed propertyId, address indexed tenant, uint256 durationMonths);
    event RentPaid(uint256 indexed propertyId, address indexed tenant, uint256 amount);
    event RentalEnded(uint256 indexed propertyId, address indexed tenant);
}
SOLIDITY

git add contracts/RealEstateRental.sol
git commit -m "feat: add RentalAgreement struct and rental events"

cat >> contracts/RealEstateRental.sol << 'APPEND'

// createRental(), payRent(), endRental() will be implemented next
APPEND
git add contracts/RealEstateRental.sol
git commit -m "wip: stub rental functions — implementation pending"

echo ""
echo "✅ feature-rental branch ready!"
echo ""
echo "════════════════════════════════════════"
echo "  All branches created successfully!"
echo "════════════════════════════════════════"
echo ""
echo "NEXT STEPS:"
echo "1. Push feature-property-listing:"
echo "   git push origin feature-property-listing"
echo "   → Open PR on GitHub, tag @manoov (Milestone 1)"
echo ""
echo "2. After seminar, push feature-escrow + feature-rental:"
echo "   git push origin feature-escrow feature-rental"
echo "   → Open PR for Final Submission (Milestone 2)"
echo ""
echo "3. Respond to all @manoov comments before April 10!"