// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../eon/utils/VersionUpgradeable.sol";

import {System} from "../../eon/systems/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils/Utils.sol";
import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import "../tables/Tables.sol";
import {IdConfigDeveloperAddress} from "../libraries/LotteryGameSystemConfigSetting.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameConstantVariableSystem")
);

contract LotteryGameConstantVariableSystem is
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

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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

    uint256 public constant ID_LotteryGameConfigDeveloperAddress =
        IdConfigDeveloperAddress;

    function setGameDeveloperAddress(
        address developerAddress_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(developerAddress_ != address(0), "developer address is zero");

        //set the lottery game developer address
        ContractUint256VariableTable.set(
            ID_LotteryGameConfigDeveloperAddress,
            addressToEntity(developerAddress_)
        );
    }

    function getDeveloperAddress() public view returns (address) {
        return
            entityToAddress(
                ContractUint256VariableTable.get(
                    ID_LotteryGameConfigDeveloperAddress
                )
            );
    }

    function setGameConfig(
        uint256 key_,
        uint256 value_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ContractUint256VariableTable.set(key_, value_);
    }

    function setGameConfig(
        uint256 key_,
        address value_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ContractUint256VariableTable.set(key_, addressToEntity(value_));
    }

    function getGameConfig(uint256 key_) external view returns (uint256) {
        return ContractUint256VariableTable.get(key_);
    }

    function getBonusRewardPercent(
        uint256 winnerLevel_
    ) public pure returns (uint256) {
        if (winnerLevel_ == 0) {
            return 70;
        }
        if (winnerLevel_ == 1) {
            return 15;
        }
        if (winnerLevel_ == 2) {
            return 5;
        }
        if (winnerLevel_ == 3) {
            return 10;
        }
        return 0;
    }

    ///@dev this is the percent of ticket get bonus
    function getTicketBonusPercent() public pure returns (uint256) {
        return 80;
    }
}
