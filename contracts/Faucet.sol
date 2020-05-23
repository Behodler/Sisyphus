pragma solidity ^0.6.2;
import "./facades/ScarcityLike.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";


contract Faucet is Ownable {
    using SafeMath for uint256;
    ScarcityLike public scarcity;
    uint256 public dripSize;
    uint256 public lastDrip;
    uint256 public dripInterval;
    uint256 public drips;

    constructor () public { //approx 375 days if average block time 15 seconds
        dripInterval = 15;
        drips = 144000;
    }

    function seed(address scx) external onlyOwner {
        scarcity = ScarcityLike(scx);
    }

    function calibrate(uint256 interval, uint256 num) public onlyOwner {
        drips = num;
        dripInterval = interval;
    }

    function drip() public {
        require(
            block.number - lastDrip >= dripInterval,
            "Too soon. Come back later."
        );
        require(
            scarcity.transfer(msg.sender, dripSize),
            "faucet balance too low to drip any more."
        );
    }

    function takeDonation(uint256 value) external {
        require(
            scarcity.transferFrom(msg.sender, address(this), value),
            "donation transferFailed"
        );
        dripSize = scarcity.balanceOf(address(this)).div(drips);
    }
}
