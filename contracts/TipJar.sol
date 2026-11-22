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
    string public name;
    uint256 public immutable targetAmount;

    bool private withdrawing;
    Tip[] private tips;

    event Tipped(address indexed sender, uint256 amount, string message);
    event Withdrawn(address indexed owner, uint256 amount);

    error ZeroTip();
    error InvalidUnlockCondition();
    error NotOwner();
    error WithdrawLocked();
    error TransferFailed();

    constructor(
        address _owner,
        string memory _name,
        uint256 _targetAmount
    ) {
        if (_targetAmount == 0) {
            revert InvalidUnlockCondition();
        }

        owner = _owner;
        name = _name;
        targetAmount = _targetAmount;
    }

    receive() external payable {
        this.tip("");
    }

    function tip(string calldata message) external payable {
        if (msg.value == 0) revert ZeroTip();

        tips.push(Tip({
            sender: msg.sender,
            amount: msg.value,
            message: message,
            timestamp: block.timestamp
        }));

        emit Tipped(msg.sender, msg.value, message);
    }

    function canWithdraw() public view returns (bool) {
        return address(this).balance >= targetAmount;
    }

    function withdraw() external {
        if (msg.sender != owner) revert NotOwner();
        if (!canWithdraw()) revert WithdrawLocked();
        if (withdrawing) revert TransferFailed();

        uint256 amount = address(this).balance;
        withdrawing = true;

        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) {
            withdrawing = false;
            revert TransferFailed();
        }

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
