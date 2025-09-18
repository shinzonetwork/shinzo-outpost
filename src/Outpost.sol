// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Outpost {
    // Errors
    error PaymentAmountTooLow(uint256 amount);
    error PolicyIdDoesNotExist(string policyId);
    error DigitalIdDoesNotExist(string identity);
    error PaymentAlreadyExpired();
    error PaymentNotExpired();
    error ZeroAddress();

    // Events
    event PaymentCreated(address indexed user, string indexed policyId, uint256 paymentIndex);
    event PaymentExpired(address indexed user, uint256 indexed paymentIndex);
    event DigitalIdCreated(address indexed user, string identity);

    // Structs
    struct AccessControlPolicy {
        string policyId;
        bytes32 policyPaymentId;
    }

    struct DigitalId {
        address user;
        string identity;
        AccessControlPolicy[] policies;
    }

    struct PaymentReceipt {
        AccessControlPolicy policy;
        uint256 amount;
        uint256 timestamp;
        uint256 expiration;
        bool expired;
    }

    // State Variables
    mapping(address => mapping(uint256 => PaymentReceipt)) public payments;
    mapping(address => uint256) public paymentCount;
    mapping(address => DigitalId) public digitalIds;

    /**
     * @notice Creates a new payment for a given policy and identity.
     * @param policyId The ID of the policy to associate with the payment.
     * @param identity The digital identity of the user.
     * @param expiration The duration in seconds until the payment expires.
     * @return paymentIndex The index of the newly created payment.
     */
    function payment(string memory policyId, string memory identity, uint256 expiration)
        public
        payable
        returns (uint256)
    {
        if (msg.value <= 0) revert PaymentAmountTooLow(msg.value);
        if (bytes(policyId).length == 0) revert PolicyIdDoesNotExist(policyId);
        if (bytes(identity).length == 0) revert DigitalIdDoesNotExist(identity);

        DigitalId storage digitalId = digitalIds[msg.sender];
        if (digitalId.user == address(0)) {
            digitalId.user = msg.sender;
            digitalId.identity = identity;
            emit DigitalIdCreated(msg.sender, identity);
        }

        bytes memory encoded = abi.encodePacked(policyId, msg.sender, block.timestamp);
        bytes32 policyPaymentId;
        assembly {
            policyPaymentId := keccak256(add(encoded, 0x20), mload(encoded))
        }

        AccessControlPolicy memory newPolicy = AccessControlPolicy(policyId, policyPaymentId);

        digitalId.policies.push(newPolicy);

        uint256 paymentIndex = paymentCount[msg.sender];
        payments[msg.sender][paymentIndex] = PaymentReceipt({
            policy: newPolicy,
            amount: msg.value,
            timestamp: block.timestamp,
            expiration: block.timestamp + expiration,
            expired: false
        });

        paymentCount[msg.sender]++;

        emit PaymentCreated(msg.sender, policyId, paymentIndex);
        return paymentIndex;
    }

    /**
     * @notice Expires a payment for a given user and payment index.
     * @param user The address of the user who made the payment.
     * @param paymentIndex The index of the payment to expire.
     * @return success True if the payment was successfully expired.
     */
    function expirePayment(address user, uint256 paymentIndex) public returns (bool) {
        if (user == address(0)) revert ZeroAddress();
        PaymentReceipt storage _payment = payments[user][paymentIndex];
        if (_payment.expired) revert PaymentAlreadyExpired();
        if (block.timestamp < _payment.expiration) revert PaymentNotExpired();

        _payment.expired = true;
        emit PaymentExpired(user, paymentIndex);
        return true;
    }

    /**
     * @notice Retrieves a payment by user and index.
     * @param user The address of the user.
     * @param paymentIndex The index of the payment.
     * @return Payment struct.
     */
    function getPayment(address user, uint256 paymentIndex) public view returns (PaymentReceipt memory) {
        if (user == address(0)) revert ZeroAddress();
        return payments[user][paymentIndex];
    }

    /**
     * @notice Retrieves the amount of a payment.
     * @param user The address of the user.
     * @param paymentIndex The index of the payment.
     * @return The payment amount.
     */
    function getPaymentAmount(address user, uint256 paymentIndex) public view returns (uint256) {
        if (user == address(0)) revert ZeroAddress();
        return payments[user][paymentIndex].amount;
    }

    /**
     * @notice Retrieves the total number of payments for a user.
     * @param user The address of the user.
     * @return The number of payments.
     */
    function getPaymentCount(address user) public view returns (uint256) {
        if (user == address(0)) revert ZeroAddress();
        return paymentCount[user];
    }

    /**
     * @notice Retrieves the Digital ID for a user.
     * @param user The address of the user.
     * @return DigitalID struct.
     */
    function getDigitalId(address user) public view returns (DigitalId memory) {
        if (user == address(0)) revert ZeroAddress();
        return digitalIds[user];
    }
}
