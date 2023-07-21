// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title ILotteryGameTicketBonusRewardSystem
/// @notice Interface for LotteryGameTicketBonusRewardSystem

interface ILotteryGameTicketBonusRewardSystem {
    /// @notice Claim ticket reward to ticket owner
    /// @param ticketId Ticket id
    /// @param ticketOwner Ticket owner
    function claimTicketRewardTo(
        uint256 ticketId,
        address ticketOwner
    ) external;
}
