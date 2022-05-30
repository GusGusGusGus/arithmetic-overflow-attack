//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

/// @title This CORRECTED contract allow a user to deposit funds, thereby locking them for a week. This shows 2 possible solutions to the exploit: updating the compiler version used or, in legacy compilers, use SafeMath
/// @author GusGusGusGus
/// @notice Deposit money to the contract and be happy.
/// @dev Correcting version of the compiler to versions ^0.8.0. solves the issue of arithmetic overflow. But just to be sure this is not deployed in lesser versions, support for safe arithmetic operations through the use of SafeMath was added
contract TimeLockVulnerable {
    using SafeMath for uint256;
    mapping(address => uint) public balances;
    mapping(address => uint) public locktime;

    /// @notice Function that allows user to deposit their funds to be timelocked
    /// @dev payable function that saves the sent value on-chain and the locktime value (timestamp of the current block + 1 week) to the locktime array
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        balances[msg.sender] = block.timestamp + 1 weeks;
    }

    /// @notice Allows a user to increase the amount of time their tokens are locked
    /// @dev Increases locktime property value to received arguments 
    /// @param _secondsToIncrease in seconds
    function increaseTimeLock(uint _secondsToIncrease) public {
        locktime[msg.sender] =  locktime[msg.sender].add(_secondsToIncrease);
        console.log("Increased timelock '%s' seconds...", _secondsToIncrease);
    } 

    /// @notice Function that allows user to withdraw their funds
    /// @dev SAFE withdraw function
    function withdraw() public { 
        require(balances[msg.sender] > 0, "Insufficient funds");
        //now this assertion will work
        require(block.timestamp > locktime[msg.sender], "Lock time has not expired yet");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        payable(msg.sender).transfer(amount);

    }
}
