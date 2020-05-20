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
    }

    function seed(address scx) external {
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
        uint256 rewardForDeposed = currentBuyout.mul(66).div(100);
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
        uint256 daysElapsed = (now - BuyoutTime) / (1 days);
        uint256 proportion = 100 - (daysElapsed > 100 ? 100 : daysElapsed);

        uint256 newBuyoutAmount = BuyoutAmount.mul(proportion).div(100);

        return newBuyoutAmount <= BuyoutAmount ? newBuyoutAmount : BuyoutAmount;
    }
}
