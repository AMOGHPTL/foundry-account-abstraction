// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// TO USE THIS CONTRACT UNCOMMENT EVERYTHING AND SPECIFY THAT CONTRACT S IAccount and Ownable

// zkSync era imports
// import {
//     IAccount,
//     ACCOUNT_VALIDATION_SUCCESS_MAGIC
// } from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
// import {
//     Transaction,
//     MemoryTransactionHelper
// } from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
// import {
//     SystemContractsCaller
// } from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/SystemContractsCaller.sol";
// import {
//     NONCE_HOLDER_SYSTEM_CONTRACT,
//     BOOTLOADER_FORMAL_ADDRESS,
//     DEPLOYER_SYSTEM_CONTRACT
// } from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
// import {INonceHolder} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/INonceHolder.sol";
// import {Utils} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/Utils.sol";

// // OZ imports
// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Lifecycle of a type 113 (0x71) transaction
 * msg.sender is bootloader system contract
 *
 * Phase 1 validation
 * 1. The user sends the txn to the "zkSync API client" (sort of a light node)
 * 2. The zkSync API client checks to see the nonce is unique by quering the NonceHolder system contracts
 * 3. The zkSync API client call the validateTransaction, which must update the nonce
 * 4. The zkSync API client checks if the nonce is updated
 * 5. The zkSync API client calls the payForTransaction or prepareForPaymaster & validateAndForPaymasterTransaction
 * 6. The zkSync API client verifies that the bootloader gets paid
 *
 * Phase 2 execution
 * 7. The zkSync API client passes the validated transaction to the main node / sequencer
 * 8. The main node calls executeTransaction
 * 9. If a paymaster was used,  the postTransaction is called
 */

contract ZkMinimalAccount {
    // using MemoryTransactionHelper for Transaction;
    // ////////////////////////////
    // ////////   Errors  /////////
    // ////////////////////////////
    // error ZkMinimalAccount__NotEnoughBalance();
    // error ZkMinimalAccount__NotFromBootLoader();
    // error ZkMinimalAccount__ExecutionFailed();
    // error ZkMinimalAccount__NotFromBootLoaderOrOwner();
    // error ZkMinimalAccount__FailedToPay();
    // error ZkMinimalAccount__VaidationFailed();
    // ////////////////////////////
    // ////////  modifier /////////
    // ////////////////////////////
    // modifier requireFromBootLoader() {
    //     if (msg.sender != BOOTLOADER_FORMAL_ADDRESS) {
    //         revert ZkMinimalAccount__NotFromBootLoader();
    //     }
    //     _;
    // }
    // modifier requireFromBootLoaderOrOwner() {
    //     if (msg.sender != BOOTLOADER_FORMAL_ADDRESS && msg.sender != owner()) {
    //         revert ZkMinimalAccount__NotFromBootLoaderOrOwner();
    //     }
    //     _;
    // }
    // ////////////////////////////
    // //////// Functions /////////
    // ////////////////////////////
    // constructor() Ownable(msg.sender) {}
    // ////////////////////////////
    // //////// External  /////////
    // ////////////////////////////
    // function recieve() external payable {}
    // /**
    //  *
    //  * @notice must increase the nonce
    //  * @notice must validate the transaction (check the owner signed the transaction)
    //  * @notice also check to see if the we have enough money in our account
    //  */
    // function validateTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
    //     external
    //     payable
    //     requireFromBootLoader
    //     returns (bytes4 magic)
    // {
    //     return _validateTransaction(_transaction);
    // }
    // // same as execute function in the ethereum account abstraction
    // function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
    //     external
    //     payable
    //     requireFromBootLoaderOrOwner
    // {
    //     _executeTransaction(_transaction);
    // }
    // // you sign a tx
    // // send the signed tx to your friend
    // // They can send it by calling this function
    // // There is no point in providing possible signed hash in the `executeTransactionFromOutside` method,
    // // since it typically should not be trusted.
    // function executeTransactionFromOutside(Transaction memory _transaction) external payable {
    //     bytes4 magic = _validateTransaction(_transaction);
    //     if (magic == bytes4(0)) {
    //         revert ZkMinimalAccount__VaidationFailed();
    //     }
    //     _executeTransaction(_transaction);
    // }
    // // similar to payPreFunds function in the ethereum account abstraction
    // function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
    //     external
    //     payable
    // {
    //     bool success = _transaction.payToTheBootloader();
    //     if (!success) {
    //         revert ZkMinimalAccount__FailedToPay();
    //     }
    // }
    // // This function is called before calling the payForTransaction when you have a paymaster setup
    // // paymaster is someone who is paying for the txn it can be someone else paying for your transactions
    // function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
    //     external
    //     payable {}
    // ////////////////////////////
    // //////// Internal  /////////
    // ////////////////////////////
    // function _validateTransaction(Transaction memory _transaction) internal returns (bytes4 magic) {
    //     SystemContractsCaller.systemCallWithPropagatedRevert(
    //         uint32(gasleft()),
    //         address(NONCE_HOLDER_SYSTEM_CONTRACT),
    //         0,
    //         abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (_transaction.nonce))
    //     );
    //     // Check for fee to pay
    //     uint256 totalRequiredBalance = _transaction.totalRequiredBalance();
    //     if (totalRequiredBalance > address(this).balance) {
    //         revert ZkMinimalAccount__NotEnoughBalance();
    //     }
    //     // Check the signature
    //     bytes32 txHash = _transaction.encodeHash();
    //     address signer = ECDSA.recover(txHash, _transaction.signature);
    //     bool isValid = signer == owner();
    //     if (isValid) {
    //         magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC;
    //     } else {
    //         magic = bytes4(0);
    //     }
    //     // return the "magic" number
    //     return magic;
    // }
    // function _executeTransaction(Transaction memory _transaction) internal {
    //     address to = address(uint160(_transaction.to));
    //     uint128 value = Utils.safeCastToU128(_transaction.value);
    //     bytes memory data = _transaction.data;
    //     if (to == address(DEPLOYER_SYSTEM_CONTRACT)) {
    //         uint32 gas = uint32(gasleft());
    //         SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
    //     } else {
    //         bool success;
    //         assembly {
    //             success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
    //         }
    //         if (!success) {
    //             revert ZkMinimalAccount__ExecutionFailed();
    //         }
    //     }
    // }

    }
