// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../../eon/systems/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {addressToEntity, entityToAddress} from "../../../eon/utils/Utils.sol";

import {MiniGameBonusTable} from "../tables/MiniGameBonusTable.sol";

import {StoreU256SetSystem, ID as StoreU256SetSystemID} from "../../../eon/systems/StoreU256SetSystem.sol";
import {MiniGameBonusListTable, IdBonusAddressList} from "../tables/MiniGameBonusListTable.sol";

uint256 constant ID = uint256(keccak256("game.systems.MiniGameBonusSystem"));

contract MiniGameBonusSystem is
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

    function winBonusExternal(
        address from,
        uint256 amount
    ) external nonReentrant {
        _winBonus(from, amount);
    }

    function winBonusExternalSkipRoleCheck(
        address from,
        uint256 amount
    ) external nonReentrant {
        this.winBonus(from, amount);
    }

    function winBonus(
        address from,
        uint256 amount
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        _winBonus(from, amount);
    }

    function _winBonus(address from, uint256 amount) internal {
        uint256 bonus = getBonusByAdddress(from);
        MiniGameBonusTable.set(from, bonus + amount);
    }

    function getBonus() public view returns (uint256) {
        address from = _msgSender();
        return getBonusByAdddress(from);
    }

    function bonusOf(address from) public view returns (uint256) {
        return getBonusByAdddress(from);
    }

    function getBonusByAdddress(address from) internal view returns (uint256) {
        return MiniGameBonusTable.get(from);
    }

    function addBonusAddressList(address from) public {
        MiniGameBonusListTable.add(IdBonusAddressList, addressToEntity(from));
    }

    function getBonusAddressList() public view returns (address[] memory) {
        return MiniGameBonusListTable.valuesAsAddress(IdBonusAddressList);
    }

    function removeBonusAddressList(address from) public {
        MiniGameBonusListTable.remove(
            IdBonusAddressList,
            addressToEntity(from)
        );
    }
}
