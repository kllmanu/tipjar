// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SplitTipJar {
    struct Tip {
        address sender;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    address public immutable owner;
    address public splitRecipient;
    uint16 public splitBps;
    Tip[] private tips;

    event TipReceived(
        address indexed sender,
        uint256 totalAmount,
        uint256 splitAmount,
        string message
    );

    error ZeroTip();
    error InvalidSplit();
    error NotOwner();
    error TransferFailed();

    constructor(address _splitRecipient, uint16 _splitBps) {
        if (_splitBps > 10_000) revert InvalidSplit();
        owner = msg.sender;
        splitRecipient = _splitRecipient;
        splitBps = _splitBps;
    }

    function tip(string calldata message) external payable {
        if (msg.value == 0) revert ZeroTip();

        uint256 splitAmount = (msg.value * splitBps) / 10_000;
        uint256 ownerAmount = msg.value - splitAmount;

        tips.push(Tip({
            sender: msg.sender,
            amount: msg.value,
            message: message,
            timestamp: block.timestamp
        }));

        if (splitAmount > 0 && splitRecipient != address(0)) {
            (bool okSplit, ) = payable(splitRecipient).call{value: splitAmount}("");
            if (!okSplit) revert TransferFailed();
        }

        if (ownerAmount > 0) {
            (bool okOwner, ) = payable(owner).call{value: ownerAmount}("");
            if (!okOwner) revert TransferFailed();
        }

        emit TipReceived(msg.sender, msg.value, splitAmount, message);
    }

    function getTipsCount() external view returns (uint256) {
        return tips.length;
    }

    function getTip(uint256 index) external view returns (Tip memory) {
        return tips[index];
    }
}
