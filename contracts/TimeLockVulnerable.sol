//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "hardhat/console.sol";

/// @title This VULNERABLE contract allow a user to deposit funds, thereby locking them for a week.
/// @author GusGusGusGus
/// @notice Deposit money to the contract and cry.
/// @dev Purposefully outdated version of the compiler (0.6.0) and no support for safe arithmetic operations
contract TimeLockVulnerable {
    mapping(address => uint) public balances;
    mapping(address => uint) public locktime;

    /// @notice Function that allows user to deposit their funds to be timelocked
    /// @dev payable function that saves the sent value on-chain and the locktime value (timestamp of the current block + 1 week) to the locktime array
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        balances[msg.sender] = now + 1 weeks;
    }

    /// @notice Allows a user to increase the amount of time their tokens are locked
    /// @dev Increases locktime property value to received arguments 
    /// @param _secondsToIncrease in seconds
    function increaseTimeLock(uint _secondsToIncrease) public {
        locktime[msg.sender] += _secondsToIncrease;
        console.log("Increased timelock '%s' seconds...", _secondsToIncrease);
    } 

    /// @notice Function that allows user to withdraw their funds
    /// @dev VULNERABLE withdraw function
    function withdraw() public { 
        require(balances[msg.sender] > 0, "Insufficient funds");
        //vulnerable
        require(now > locktime[msg.sender], "Lock time has not expired yet");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        require(msg.sender.call{value: amount}(""), "Failed to send Ether");
    }
}
