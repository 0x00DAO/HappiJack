// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../eon/utils/VersionUpgradeable.sol";

import {System} from "../../eon/systems/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";
import "../tables/Tables.sol";
import "../collections/CollectionTables.sol";

import {GameSystems} from "./GameSystems.sol";
import {LotteryGameLotteryCoreSystem, ID as LotteryGameLotteryCoreSystemID} from "./LotteryGameLotteryCoreSystem.sol";
import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameLotteryResultVerifyBonusPoolRefundSystem, ID as LotteryGameLotteryResultVerifyBonusPoolRefundSystemID} from "./LotteryGameLotteryResultVerifyBonusPoolRefundSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameLotteryResultVerifySystem")
);

contract LotteryGameLotteryResultVerifySystem is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    System,
    ReentrancyGuardUpgradeable,
    VersionUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address root_) public initializer {
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __System_init(ID, root_);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    /// custom logic here

    event LotteryGameResultVerified(
        uint256 indexed lotteryGameId,
        uint256 indexed luckyNumber
    );

    function verify(
        uint256 lotteryGameId_
    ) external nonReentrant whenNotPaused {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_),
            "Lottery game does not exist"
        );

        //check if lottery game is in the correct status
        require(
            LotteryGameTable.getStatus(lotteryGameId_) ==
                uint256(LotteryGameStatus.Active),
            "Lottery game is not in the correct status"
        );

        //check if lottery game has ended
        require(
            LotteryGameConfigTable.getStartTime(lotteryGameId_) +
                LotteryGameConfigTable.getDuring(lotteryGameId_) <=
                block.timestamp,
            "Lottery game has not ended"
        );

        //set lottery game status to verified
        LotteryGameTable.setStatus(
            lotteryGameId_,
            uint256(LotteryGameStatus.Ended)
        );

        //remove lottery game from active list
        LotteryGameActiveGameCollectionTable.remove(lotteryGameId_);
        //add lottery game to history list
        LotteryGameHistoryGameCollectionTable.add(lotteryGameId_);

        uint256 currentLuckyNumber = LotteryGameLuckyNumTable.getCurrentNumber(
            lotteryGameId_
        );

        uint256 ticketCount = LotteryGameTicketTable.getTicketSoldCount(
            lotteryGameId_
        );

        if (ticketCount > 0) {
            //computeLotteryResult
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).computeLotteryResult(lotteryGameId_, currentLuckyNumber);
        }

        if (ticketCount == 0) {
            //If no one buys a ticket, return all the prize pool to the lottery initiator
            GameSystems
                .getLotteryGameBonusPoolWithdrawSystem()
                .withdrawBonusAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    LotteryGameConfigTable.getOwner(lotteryGameId_),
                    LotteryGameBonusPoolTable.getBonusAmount(lotteryGameId_) -
                        LotteryGameBonusPoolTable.getBonusAmountWithdraw(
                            lotteryGameId_
                        )
                );
        } else {
            //If someone buys a ticket
            //distribute owner fee
            GameSystems
                .getLotteryGameBonusPoolWithdrawSystem()
                .withdrawOwnerFeeAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    LotteryGameConfigTable.getOwner(lotteryGameId_),
                    LotteryGameBonusPoolTable.getOwnerFeeAmount(lotteryGameId_)
                );

            address developAddress = GameSystems
                .getLotteryGameConstantVariableSystem()
                .getDeveloperAddress();
            if (developAddress != address(0)) {
                //distribute developer fee
                GameSystems
                    .getLotteryGameBonusPoolWithdrawSystem()
                    .withdrawDevelopFeeAmountToWalletSafeBoxETH(
                        lotteryGameId_,
                        developAddress,
                        LotteryGameBonusPoolTable.getDevelopFeeAmount(
                            lotteryGameId_
                        )
                    );
            }

            // Distribute validator income
            GameSystems
                .getLotteryGameBonusPoolWithdrawSystem()
                .withdrawVerifyFeeAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    _msgSender(),
                    LotteryGameBonusPoolTable.getVerifyFeeAmount(lotteryGameId_)
                );

            //If the winner cannot cover the prize money of 1,2,3, etc., then the prize money will be returned to the initiator
            LotteryGameLotteryResultVerifyBonusPoolRefundSystem(
                getSystemAddress(
                    LotteryGameLotteryResultVerifyBonusPoolRefundSystemID
                )
            ).bonusPoolRefund(lotteryGameId_);
        }

        //emit event
        emit LotteryGameResultVerified(lotteryGameId_, currentLuckyNumber);
    }
}
