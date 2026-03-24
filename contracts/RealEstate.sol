// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RealEstate - Complete Smart Contract
/// @notice Handles property listing, escrow, rental and disputes
contract RealEstate {

    // ─────────────────────────────────────────
    // Enums & Structs
    // ─────────────────────────────────────────

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

    struct RentalAgreement {
        address tenant;
        uint256 rentPerMonth;
        uint256 startTimestamp;
        uint256 durationMonths;
        uint256 depositPaid;
        bool active;
    }

    // ─────────────────────────────────────────
    // State Variables
    // ─────────────────────────────────────────

    address public contractOwner;
    uint256 public propertyCount;

    mapping(uint256 => Property)        public properties;
    mapping(uint256 => Escrow)          public escrows;
    mapping(uint256 => RentalAgreement) public rentals;

    // ─────────────────────────────────────────
    // Events
    // ─────────────────────────────────────────

    event PropertyListed(uint256 indexed propertyId, address indexed owner, uint256 price);
    event PropertyPriceUpdated(uint256 indexed propertyId, uint256 newPrice);
    event EscrowDeposited(uint256 indexed propertyId, address indexed buyer, uint256 amount);
    event EscrowConfirmed(uint256 indexed propertyId, address indexed confirmedBy);
    event EscrowReleased(uint256 indexed propertyId, address indexed seller, uint256 amount);
    event EscrowRefunded(uint256 indexed propertyId, address indexed buyer, uint256 amount);
    event DisputeRaised(uint256 indexed propertyId, address indexed raisedBy);
    event DisputeResolved(uint256 indexed propertyId, string resolution);
    event PropertyOwnershipTransferred(uint256 indexed propertyId, address indexed from, address indexed to);
    event RentalCreated(uint256 indexed propertyId, address indexed tenant, uint256 durationMonths);
    event RentPaid(uint256 indexed propertyId, address indexed tenant, uint256 amount);
    event RentalEnded(uint256 indexed propertyId, address indexed tenant);

    // ─────────────────────────────────────────
    // Modifiers
    // ─────────────────────────────────────────

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Not contract owner");
        _;
    }

    modifier propertyExists(uint256 _id) {
        require(properties[_id].exists, "Property does not exist");
        _;
    }

    // ─────────────────────────────────────────
    // Constructor
    // ─────────────────────────────────────────

    constructor() {
        contractOwner = msg.sender;
    }

    // ─────────────────────────────────────────
    // Property Listing
    // ─────────────────────────────────────────

    /// @notice List a new property for sale
    function listProperty(string calldata _location, uint256 _priceWei) external returns (uint256) {
        require(_priceWei > 0, "Price must be > 0");
        propertyCount++;
        uint256 id = propertyCount;
        properties[id] = Property(id, msg.sender, _location, _priceWei, PropertyStatus.Available, true);
        emit PropertyListed(id, msg.sender, _priceWei);
        return id;
    }

    /// @notice Update asking price (owner only)
    function updatePrice(uint256 _propertyId, uint256 _newPrice) external propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        require(msg.sender == p.owner, "Not property owner");
        require(p.status == PropertyStatus.Available, "Not available");
        p.priceWei = _newPrice;
        emit PropertyPriceUpdated(_propertyId, _newPrice);
    }

    // ─────────────────────────────────────────
    // Escrow / Purchase Flow
    // ─────────────────────────────────────────

    /// @notice Buyer deposits exact asking price into escrow
    function depositEscrow(uint256 _propertyId) external payable propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        require(p.status == PropertyStatus.Available, "Property not available");
        require(msg.sender != p.owner, "Owner cannot buy own property");
        require(msg.value == p.priceWei, "Must send exact price");

        p.status = PropertyStatus.UnderEscrow;
        escrows[_propertyId] = Escrow(msg.sender, msg.value, false, false, false, false);
        emit EscrowDeposited(_propertyId, msg.sender, msg.value);
    }

    /// @notice Buyer and seller both confirm to release escrow
    function confirmTransaction(uint256 _propertyId) external propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        Escrow storage e = escrows[_propertyId];
        require(p.status == PropertyStatus.UnderEscrow, "Not in escrow");
        require(!e.disputed, "Disputed — resolve first");
        require(!e.released, "Already released");

        if (msg.sender == e.buyer)    e.buyerConfirmed  = true;
        else if (msg.sender == p.owner) e.sellerConfirmed = true;
        else revert("Not a party to this escrow");

        emit EscrowConfirmed(_propertyId, msg.sender);

        if (e.buyerConfirmed && e.sellerConfirmed) {
            _releaseEscrow(_propertyId);
        }
    }

    /// @dev Internal: release funds and transfer ownership
    function _releaseEscrow(uint256 _propertyId) internal {
        Property storage p = properties[_propertyId];
        Escrow storage e = escrows[_propertyId];

        e.released = true;
        address seller = p.owner;
        uint256 amount = e.amountDeposited;

        p.owner = e.buyer;
        p.status = PropertyStatus.Sold;

        emit PropertyOwnershipTransferred(_propertyId, seller, e.buyer);
        emit EscrowReleased(_propertyId, seller, amount);

        (bool sent, ) = payable(seller).call{value: amount}("");
        require(sent, "Transfer to seller failed");
    }

    // ─────────────────────────────────────────
    // Dispute Resolution
    // ─────────────────────────────────────────

    /// @notice Raise a dispute (buyer or seller)
    function raiseDispute(uint256 _propertyId) external propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        Escrow storage e = escrows[_propertyId];
        require(p.status == PropertyStatus.UnderEscrow, "Not in escrow");
        require(msg.sender == e.buyer || msg.sender == p.owner, "Not a party");
        require(!e.released, "Already released");

        e.disputed = true;
        emit DisputeRaised(_propertyId, msg.sender);
    }

    /// @notice Contract owner resolves dispute
    /// @param _refundBuyer true = refund buyer, false = pay seller
    function resolveDispute(uint256 _propertyId, bool _refundBuyer) external onlyContractOwner propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        Escrow storage e = escrows[_propertyId];
        require(e.disputed, "No active dispute");
        require(!e.released, "Already released");

        e.released = true;
        e.disputed = false;

        if (_refundBuyer) {
            p.status = PropertyStatus.Available;
            uint256 refund = e.amountDeposited;
            e.amountDeposited = 0;
            emit DisputeResolved(_propertyId, "Refunded to buyer");
            emit EscrowRefunded(_propertyId, e.buyer, refund);
            (bool sent, ) = payable(e.buyer).call{value: refund}("");
            require(sent, "Refund failed");
        } else {
            _releaseEscrow(_propertyId);
            emit DisputeResolved(_propertyId, "Paid to seller");
        }
    }

    // ─────────────────────────────────────────
    // Rental Agreement
    // ─────────────────────────────────────────

    /// @notice Owner creates a rental for their property
    function createRental(
        uint256 _propertyId,
        address _tenant,
        uint256 _rentPerMonth,
        uint256 _durationMonths
    ) external payable propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        require(msg.sender == p.owner, "Not property owner");
        require(p.status == PropertyStatus.Available, "Not available");
        require(_tenant != address(0), "Invalid tenant");
        require(_rentPerMonth > 0, "Rent must be > 0");
        require(_durationMonths > 0, "Duration must be > 0");
        require(msg.value == _rentPerMonth, "Deposit must equal 1 month rent");

        p.status = PropertyStatus.Rented;
        rentals[_propertyId] = RentalAgreement(_tenant, _rentPerMonth, block.timestamp, _durationMonths, msg.value, true);
        emit RentalCreated(_propertyId, _tenant, _durationMonths);
    }

    /// @notice Tenant pays monthly rent
    function payRent(uint256 _propertyId) external payable propertyExists(_propertyId) {
        RentalAgreement storage r = rentals[_propertyId];
        require(r.active, "No active rental");
        require(msg.sender == r.tenant, "Not the tenant");
        require(msg.value == r.rentPerMonth, "Incorrect rent amount");

        emit RentPaid(_propertyId, msg.sender, msg.value);

        (bool sent, ) = payable(properties[_propertyId].owner).call{value: msg.value}("");
        require(sent, "Rent transfer failed");
    }

    /// @notice Owner ends rental and returns deposit to tenant
    function endRental(uint256 _propertyId) external propertyExists(_propertyId) {
        Property storage p = properties[_propertyId];
        RentalAgreement storage r = rentals[_propertyId];
        require(msg.sender == p.owner, "Not property owner");
        require(r.active, "No active rental");

        r.active = false;
        p.status = PropertyStatus.Available;

        uint256 deposit = r.depositPaid;
        r.depositPaid = 0;

        emit RentalEnded(_propertyId, r.tenant);

        (bool sent, ) = payable(r.tenant).call{value: deposit}("");
        require(sent, "Deposit return failed");
    }

    // ─────────────────────────────────────────
    // View Functions
    // ─────────────────────────────────────────

    function getProperty(uint256 _id) external view propertyExists(_id) returns (Property memory) {
        return properties[_id];
    }

    function getEscrow(uint256 _id) external view returns (Escrow memory) {
        return escrows[_id];
    }

    function getRental(uint256 _id) external view returns (RentalAgreement memory) {
        return rentals[_id];
    }

    // ─────────────────────────────────────────
    // Safety
    // ─────────────────────────────────────────

    receive() external payable {
        revert("Use contract functions to send ETH");
    }
}