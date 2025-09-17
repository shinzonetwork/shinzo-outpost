// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Outpost {
    //accepts payment
    //stores memory of payment
    //allows payment function to be 
    //payment(user did, policy id, payment amount)

    error PaymentAmountTooLow(uint256 amount);
    error PolicyIdDoesNotExist(string policyId);
    error DigitalIdDoesNotExist(string identity);
    error PaymentAlreadyExpired();
    error PaymentNotExpired();

    event PaymentCreated(address indexed user, string indexed policyId, uint256 paymentIndex);
    event PaymentExpired(address indexed user, uint256 indexed paymentIndex);


    // A ACP Transaction is required to create the connection between a user address and to be able spend and the documents that user can access
    struct AccessControlPolicy{
        string policyId;
        string policyPaymentId;
    }


    // A Digital ID is a unique key for a user; the struct stores the user's address, identity string, and all the access control policies associated with the user
    struct DigitalID{
        address user;
        string identity; 
        AccessControlPolicy[] policies; 
    }
    // TODO: function to remove policy from list



    struct Payment{
        AccessControlPolicy policy;

        uint256 amount;
        uint256 timestamp;
        uint256 expiration;
        bool expired;
    }

    constructor() {
        payments[address(0)] = new Payment[](0);
    }

    mapping(address => Payment[]) public payments;
    mapping(address => DigitalID) public digitalIds;

    function helpmeout() public {

    }

    function payment(string memory policyId, string memory identity, uint256 expiration) public payable returns (uint256) {
        if(msg.value <= 0) revert PaymentAmountTooLow(msg.value);
        if(bytes(policyId).length == 0) revert PolicyIdDoesNotExist(policyId);
        if (bytes(identity).length == 0) revert DigitalIdDoesNotExist(identity);

        DigitalID storage digitalId = digitalIds[msg.sender];
        if (digitalId.user == address(0)) {
            digitalId.user = msg.sender;
        }
        digitalId.identity = identity;

        string memory policyPaymentId = string(abi.encodePacked(keccak256(abi.encodePacked(policyId, msg.sender, block.timestamp))));

        AccessControlPolicy memory newPolicy = AccessControlPolicy(policyId, policyPaymentId);

        digitalId.policies.push(newPolicy);

        payments[msg.sender].push(Payment({
            policy: newPolicy,
            amount: msg.value,
            timestamp: block.timestamp,
            expiration: block.timestamp + expiration,
            expired: false
        }));
        uint256 paymentIndex = payments[msg.sender].length;
        emit PaymentCreated(msg.sender, policyId, paymentIndex);
        return paymentIndex;
    }

    function expirePayment(address user, uint256 paymentIndex) public returns (bool) {
        Payment storage _payment = payments[user][paymentIndex];
        if (_payment.expired) revert PaymentAlreadyExpired();
        if (block.timestamp < _payment.expiration) revert PaymentNotExpired();
        payments[user][paymentIndex].expired = true;
        emit PaymentExpired(user, paymentIndex);
        return true;
    }   

    function getPayment(address user, uint256 paymentIndex) public view returns (Payment memory) {
        return payments[user][paymentIndex];
    }

    function getPaymentAmount(address user, uint256 paymentIndex) public view returns (uint256) {
        return payments[user][paymentIndex].amount;
    }



    function getPaymentCount(address user) public view returns (uint256) {
        return payments[user].length;
    }

    function getDigitalId(address user) public view returns (DigitalID memory) {
        return digitalIds[user];
    }

    function getPayments(address user) public view returns (Payment[] memory) {
        return payments[user];
    }
}