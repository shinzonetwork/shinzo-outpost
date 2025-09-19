# Shinzo Outpost – Payment Gateway

The Outpost contract is a payment gateway for the Shinzo Network. It enables smart contracts and users to make logic-driven payments tied to digital identities and access control policies. Outposts are deployed on the networks they serve, powering Shinzo’s decentralized indexing economy through trustless, verifiable payments.

## ✨ Features

Accepts and records payments from users.

Associates payments with a Digital ID (unique per user).

Links each payment to an Access Control Policy (ACP).

Supports payment expiration and allows expired payments to be updated.

Exposes queries for inspecting user payments and policies.

## 📖 Core Concepts

Digital ID
A unique identifier for a user that stores their address, identity string, and associated policies.

Access Control Policy (ACP)
Represents the link between a user and the resources/services they can access, tied to a payment.

Payment
Tracks the amount, timestamp, expiration, and whether the payment has expired.

## 🔑 Contract Overview
### Errors

PaymentAmountTooLow(uint256 amount) – Reverts if no ETH was sent.

PolicyIdDoesNotExist(string policyId) – Reverts if policy ID is empty.

DigitalIdDoesNotExist(string identity) – Reverts if identity is empty.

PaymentAlreadyExpired() – Reverts if attempting to expire an already expired payment.

PaymentNotExpired() – Reverts if attempting to expire before expiration.

### Events

PaymentCreated(address user, string policyId, uint256 paymentIndex)

PaymentExpired(address user, uint256 paymentIndex)

### Key Functions

## Key Functions

| Function | Description |
|----------|-------------|
| `payment(string policyId, string identity, uint256 expiration)` | Accepts a payment, links a user’s Digital ID to a Role, stores the payment details, and returns the payment index (count). |
| `expirePayment(address user, uint256 paymentIndex)` | Marks a payment as expired once its expiration timex` has passed. |
| `getPayment(address user, uint256 index)` | Retrieves a specific payment by index for a given user. |
| `getPaymentAmount(address user, uint256 index)` | Returns the amount of a specific payment. |
| `getPaymentCount(address user)` | Returns the total number of payments associated with a user. |
| `getDigitalId(address user)` | Retrieves the Digital ID details for a user. |
| `getPayments(address user)` | Returns all payments linked to a specific user. |
| `mapping(address => mapping(uint256 => PaymentReceipt)) public payments` | Returns the PaymentReceipt from an address & payment index. |
| `mapping(address => uint256) public paymentCount` | Returns the payment count for an address. |
| `mapping(address => DigitalId) public digitalIds` | Returns the DID from an address. |



## 🛠️ Development (Foundry)

### Prerequisites

[Foundry](#foundry)

Node.js & Yarn/NPM (for scripts & tooling if needed)

Install & Build
### Clone the repo
```shell
git clone https://github.com/shinzonetwork/shinzo-outpost.git
cd shinzo-outpost
```
### Install dependencies
```shell
forge install
```
### Build contracts
```shell
forge build
```
### Run Tests
```shell
forge test -vv
```
*Deploy (example)*
forge script script/DeployOutpost.s.sol:DeployOutpost \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast

### 🔒 Security Notes

Payments are stored on-chain and immutable except for expiration status.

Ensure correct expiration values when calling payment().

This contract is unaudited and should not be used in production without review.


### Foundry

[Foundry](https://github.com/foundry-rs/foundry) is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

[Foundry Documentation](https://book.getfoundry.sh/)

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
