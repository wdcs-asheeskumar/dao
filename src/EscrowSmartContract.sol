// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract EscrowSmartContract {
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public escrowExpirationTime;
    uint256 public amountDeposited;

    bool public reciptConfirmed;
    bool public fundsReleased;
    bool public refundApproved;

    mapping(address => bool) public refunds;

    enum Status {
        Pending,
        Completed,
        Disputed
    }

    Status public status;

    constructor(address _seller, address _arbiter) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
    }

    /// @dev function to deposit in Escrow Contract and start an Escrow
    function createEscrow(
        uint256 _value,
        uint256 _escrowExpirationTime
    ) public payable {
        require(msg.sender.balance >= _value, "insufficient balance");
        require(msg.sender == buyer, "only buyer can create an escrow");
        amountDeposited = _value;
        escrowExpirationTime =
            block.timestamp +
            _escrowExpirationTime *
            1 seconds;
        status = Status.Pending;
        payable(address(this)).transfer(amountDeposited);
    }

    /// @dev Buyer getting recipt
    function getRecipt() public {
        require(msg.sender == buyer, "only buyer can approve the recipt");
        require(reciptConfirmed == false, "recipt is already confirmed");
        require(fundsReleased == false, "funds have already been release");
        reciptConfirmed = true;
    }

    /// @dev Arbiter releasing funds to the seller
    function releaseFund() public payable {
        require(msg.sender == arbiter, "only arbiter can approve the release");
        require(reciptConfirmed == true, "recipt has not been confirmed");
        require(fundsReleased == false, "funds has already been released");
        fundsReleased = true;
        status = Status.Completed;
        payable(seller).transfer(amountDeposited);
    }

    /// @dev Approving the refund to the buyer
    function approveRefund() public {
        require(
            refunds[msg.sender] == false,
            "refunds has already been confirmed"
        );
        require(
            fundsReleased == false,
            "funds has already been send to the seller"
        );
        refunds[msg.sender] = true;
    }

    /// @dev Function to refund the buyer
    function refundFunds() public payable {
        require(refundApproved == false, "refund has already been approved");
        require(refunds[seller] == true, "the seller has not approved refunds");
        require(
            refunds[arbiter] == true,
            "the arbiter has not approved refunds"
        );
        require(fundsReleased == false, "funds has already been released");
        status = Status.Disputed;
        payable(buyer).transfer(amountDeposited);
    }

    /// @dev Function called when the escrow gets expired.
    function escrowExpiration() public payable {
        require(msg.sender == buyer, "only buyer can ask for refund");
        require(
            block.timestamp > escrowExpirationTime,
            "the escrow is still active"
        );
        require(
            msg.sender == buyer,
            "only the buyer can execute this function if the services are not provided before the escrow expirations time"
        );
        require(
            fundsReleased == false,
            "funds has already been released in the buye's address"
        );
        payable(buyer).transfer(amountDeposited);
    }
}
