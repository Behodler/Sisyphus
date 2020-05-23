pragma solidity ^0.6.2;

abstract contract FaucetLike {
    function takeDonation(uint256 value) external virtual  ;
}
