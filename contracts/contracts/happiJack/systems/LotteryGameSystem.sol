// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus} from "../tables/LotteryGameStatus.sol";
import {IdCounterTable} from "../tables/IdCounterTable.sol";
import {LotteryGameTable} from "../tables/LotteryGameTable.sol";
import {LotteryGameConfigTable} from "../tables/LotteryGameConfigTable.sol";

uint256 constant ID = uint256(keccak256("happiJack.systems.LotteryGameSystem"));

contract LotteryGameSystem is
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

    uint256 public constant ID_LOTTERY_GAME =
        uint256(keccak256("happiJack.id.LotteryGame"));

    event LotteryGameCreated(
        uint256 indexed lotteryGameId,
        address indexed owner,
        uint256 startTime,
        uint256 endTime
    );

    function createLotteryGame(
        string memory ad_,
        uint256 startTime_,
        uint256 during_
    ) external payable nonReentrant whenNotPaused returns (uint256) {
        require(
            AddressUpgradeable.isContract(_msgSender()) == false,
            "sender is contract"
        );

        // uint256 endTime_ = startTime_ + during_;
        // require(during_ >= 12 hours, "during is too short");
        // require(endTime_ > block.timestamp, "end time is in the past");

        //get the lottery game id
        uint256 lotteryGameId = IdCounterTable.get(ID_LOTTERY_GAME);
        require(
            LotteryGameTable.getOwner(lotteryGameId) == address(0),
            "lottery game id is not empty"
        );
        //increment the id counter
        IdCounterTable.increase(ID_LOTTERY_GAME);

        //create the lottery game
        LotteryGameTable.setOwner(lotteryGameId, _msgSender());
        LotteryGameTable.setStatus(
            lotteryGameId,
            uint256(LotteryGameStatus.Active)
        );

        //set the lottery game info
        configGame(lotteryGameId, _msgSender(), ad_, startTime_, during_);

        emit LotteryGameCreated(
            lotteryGameId,
            _msgSender(),
            startTime_,
            startTime_ + during_
        );

        return lotteryGameId;
    }

    function configGame(
        uint256 lotteryGameId_,
        address owner_,
        string memory ad_,
        uint256 startTime_,
        uint256 during_
    ) internal {
        uint256 endTime_ = startTime_ + during_;
        require(during_ >= 12 hours, "during is too short");
        require(endTime_ > block.timestamp, "end time is in the past");

        //set the lottery game info
        LotteryGameConfigTable.setOwner(lotteryGameId_, owner_);
        LotteryGameConfigTable.setAd(lotteryGameId_, ad_);
        LotteryGameConfigTable.setStartTime(lotteryGameId_, startTime_);
        LotteryGameConfigTable.setDuring(lotteryGameId_, during_);
    }

    function getLotteryGame(
        uint256 lotteryGameId_
    ) public view returns (address owner, uint256 status) {
        owner = LotteryGameTable.getOwner(lotteryGameId_);
        status = LotteryGameTable.getStatus(lotteryGameId_);
    }
}
