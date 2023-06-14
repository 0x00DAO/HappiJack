// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";
import "../tables/Tables.sol";
import {LotteryGameLotteryCoreSystem, ID as LotteryGameLotteryCoreSystemID} from "./LotteryGameLotteryCoreSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameLotteryWalletSafeBoxSystem")
);

contract LotteryGameLotteryWalletSafeBoxSystem is
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

    event DepositETH(address indexed owner, uint256 amount);
    event WithdrawETH(address indexed owner, uint256 amount);

    function depositETH(
        address owner_
    ) public payable onlyRole(SYSTEM_INTERNAL_ROLE) {
        require(
            owner_ != address(0),
            "LotteryGameLotteryWalletSafeBoxSystem: depositETH: owner_ must not be 0 address"
        );
        require(
            msg.value > 0,
            "LotteryGameLotteryWalletSafeBoxSystem: depositETH: msg.value must be greater than 0"
        );

        LotteryGameWalletSafeBoxTable.setAmount(
            owner_,
            uint256(TokenType.ETH),
            address(0),
            LotteryGameWalletSafeBoxTable.getAmount(
                owner_,
                uint256(TokenType.ETH),
                address(0)
            ) + msg.value
        );

        emit DepositETH(owner_, msg.value);
    }

    function withdrawETH() external {
        address owner_ = _msgSender();
        uint256 amount_ = LotteryGameWalletSafeBoxTable.getAmount(
            owner_,
            uint256(TokenType.ETH),
            address(0)
        );
        require(
            owner_ != address(0),
            "LotteryGameLotteryWalletSafeBoxSystem: withdrawETH: owner_ must not be 0 address"
        );
        require(
            amount_ > 0,
            "LotteryGameLotteryWalletSafeBoxSystem: withdrawETH: amount_ must be greater than 0"
        );

        LotteryGameWalletSafeBoxTable.setAmount(
            owner_,
            uint256(TokenType.ETH),
            address(0),
            0
        );

        AddressUpgradeable.sendValue(payable(owner_), amount_);

        emit WithdrawETH(owner_, amount_);
    }
}
