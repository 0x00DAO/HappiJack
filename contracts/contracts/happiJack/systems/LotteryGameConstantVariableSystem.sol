// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";
import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import "../tables/Tables.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameConstantVariableSystem")
);

contract LotteryGameConstantVariableSystem is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    System,
    ReentrancyGuardUpgradeable
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
        uint256(keccak256("ID_LotteryGameConfigDeveloperAddress"));

    function setGameDeveloperAddress(
        address developerAddress_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
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
}
