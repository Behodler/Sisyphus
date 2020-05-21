pragma solidity ^0.6.2;
import "./facades/ScarcityLike.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";


contract Sisyphus is Ownable {
    using SafeMath for uint256;
    ScarcityLike public scarcity;
    address public CurrentMonarch;
    uint256 public BuyoutAmount;
    uint256 public BuyoutTime;
    uint256 public periodDuration;
    uint256 public totalIncrements;
    uint256 public rewardProportion;
    bool public enabled;

    event monarchChanged(
        address deposed,
        address ascended,
        uint256 Buyout,
        uint256 Payout
    );

    function enable(bool e) public onlyOwner {
        enabled = e;
    }

    constructor() public {
        enabled = true;
        rewardProportion = 66;
        totalIncrements = 100;
        periodDuration = 1 days;
    }

    function setTime(uint256 periodDurationType, uint256 _totalIncrements)
        external
        onlyOwner
    {
        require(periodDurationType < 4, "invalid period duration");
        if (periodDurationType == 0) {
            periodDuration = 1 seconds;
        } else if (periodDurationType == 1) {
            periodDuration = 1 minutes;
        } else if (periodDurationType == 2) {
            periodDuration = 1 hours;
        } else if (periodDurationType == 3) {
            periodDuration = 1 days;
        }
        totalIncrements = _totalIncrements;
    }

    function setRewardProportion(uint256 p) external onlyOwner {
        require(p <= 100, "proportion must be a percentage between 0 and 100");
        rewardProportion = p;
    }

    function seed(address scx) external onlyOwner {
        scarcity = ScarcityLike(scx);
        BuyoutTime = now;
    }

    function struggle(uint256 scarcityForwarded) public {
        require(enabled, "Sisyphus is currently disabled");
        uint256 currentBuyout = calculateCurrentBuyout();
        require(
            scarcityForwarded >= currentBuyout,
            "pretender must at forward at least as much Scx as the current buyout."
        );

        if (scarcityForwarded > 0) {
            require(
                scarcity.transferFrom(
                    msg.sender,
                    address(this),
                    scarcityForwarded
                ),
                "Scarcity transfer failed."
            );
        }

        BuyoutTime = now;
        uint256 rewardForDeposed = currentBuyout.mul(rewardProportion).div(100);
        uint256 scarcityToBurn = scarcityForwarded.sub(rewardForDeposed);

        if (CurrentMonarch != address(0) && rewardForDeposed > 0) {
            require(
                scarcity.transfer(CurrentMonarch, rewardForDeposed),
                "reward transfer failed."
            );
        } else {
            scarcityToBurn += rewardForDeposed;
        }
        if (scarcityToBurn > 0) {
            scarcity.burn(scarcityToBurn);
        }
        emit monarchChanged(
            CurrentMonarch,
            msg.sender,
            scarcityForwarded,
            rewardForDeposed
        );
        CurrentMonarch = msg.sender;
        BuyoutAmount = scarcityForwarded.mul(4);
    }

    function calculateCurrentBuyout() public view returns (uint256) {
        uint256 currentTime = now;
        if (currentTime <= BuyoutTime) {
            return BuyoutAmount;
        }
        uint256 incrementsElapsed = (now - BuyoutTime) / (periodDuration);
        uint256 incrementsLeft = totalIncrements -
            (
                incrementsElapsed > totalIncrements
                    ? totalIncrements
                    : incrementsElapsed
            );

        uint256 newBuyoutAmount = BuyoutAmount.mul(incrementsLeft).div(
            totalIncrements
        );

        return newBuyoutAmount <= BuyoutAmount ? newBuyoutAmount : BuyoutAmount;
    }
}
