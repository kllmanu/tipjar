// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TipJar {
    struct Tip {
        address sender;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    address public immutable owner;
    uint256 public immutable targetAmount;
    uint256 public immutable unlockTime;

    bool public withdrawn;
    bool private withdrawing;
    Tip[] private tips;

    event Tipped(address indexed sender, uint256 amount, string message);
    event Withdrawn(address indexed owner, uint256 amount);

    error ZeroTip();
    error InvalidUnlockCondition();
    error NotOwner();
    error WithdrawLocked();
    error AlreadyWithdrawn();
    error TransferFailed();

    constructor(address _owner, uint256 _targetAmount, uint256 _unlockTime) {
        if (_targetAmount == 0 && _unlockTime == 0) {
            revert InvalidUnlockCondition();
        }
        if (_unlockTime != 0 && _unlockTime <= block.timestamp) {
            revert InvalidUnlockCondition();
        }

        owner = _owner;
        targetAmount = _targetAmount;
        unlockTime = _unlockTime;
    }

    receive() external payable {
        this.tip("");
    }

    function tip(string calldata message) external payable {
        if (msg.value == 0) revert ZeroTip();
        if (withdrawn) revert AlreadyWithdrawn();

        tips.push(Tip({
            sender: msg.sender,
            amount: msg.value,
            message: message,
            timestamp: block.timestamp
        }));

        emit Tipped(msg.sender, msg.value, message);
    }

    function canWithdraw() public view returns (bool) {
        if (withdrawn) return false;

        bool targetReached =
            targetAmount != 0 && address(this).balance >= targetAmount;
        bool dateReached =
            unlockTime != 0 && block.timestamp >= unlockTime;

        return targetReached || dateReached;
    }

    function withdraw() external {
        if (msg.sender != owner) revert NotOwner();
        if (withdrawn) revert AlreadyWithdrawn();
        if (!canWithdraw()) revert WithdrawLocked();
        if (withdrawing) revert AlreadyWithdrawn();

        uint256 amount = address(this).balance;
        withdrawing = true;

        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) {
            withdrawing = false;
            revert TransferFailed();
        }

        withdrawn = true;
        withdrawing = false;
        emit Withdrawn(owner, amount);
    }

    function getTipsCount() external view returns (uint256) {
        return tips.length;
    }

    function getTip(uint256 index) external view returns (Tip memory) {
        return tips[index];
    }
}
