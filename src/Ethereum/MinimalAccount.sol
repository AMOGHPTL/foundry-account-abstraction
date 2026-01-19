// SDPX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    ////////////////////////////
    //////////errors////////////
    ////////////////////////////

    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);

    ///////////////////////////////////
    //////////state variables//////////
    ///////////////////////////////////

    IEntryPoint private immutable I_ENTRY_POINT;

    constructor(address entryPoint) Ownable(msg.sender) {
        I_ENTRY_POINT = IEntryPoint(entryPoint);
    }

    /////////////////////////////
    //////////modifiers//////////
    /////////////////////////////

    modifier requireFromEntryPointOrOwner() {
        _requireFromEntryPointOrOwner();
        _;
    }

    modifier requireFromEntryPoint() {
        _requireFromEntryPoint();
        _;
    }

    ////////////////////////////
    //////////external//////////
    ////////////////////////////

    function recieve() external payable {}

    function execute(address dest, uint256 value, bytes calldata functionData) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = dest.call{value: value}(functionData);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        // _validateNonce()
        _payPreFunds(missingAccountFunds);
    }

    ////////////////////////////
    //////////internal//////////
    ////////////////////////////
    function _requireFromEntryPointOrOwner() internal view {
        if (msg.sender != address(I_ENTRY_POINT) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
    }

    function _requireFromEntryPoint() internal view {
        if (msg.sender != address(I_ENTRY_POINT)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);

        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        } else {
            return SIG_VALIDATION_SUCCESS;
        }
    }

    function _payPreFunds(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
             (success);
        }
    }

    ////////////////////////////
    ////////// getters//////////
    ////////////////////////////

    function getEntryPoint() external view returns (address) {
        return address(I_ENTRY_POINT);
    }
}
