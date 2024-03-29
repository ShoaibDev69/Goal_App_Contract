// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract GoalSettingContract {
    struct Task {
        string description;
        bool isCompleted;
    }

    Task[] public tasks;
    uint256 public deposit;
    address public owner;

    event TaskCreated(uint256 taskId, string description);
    event TaskCompleted(uint256 taskId);
    event DepositWithdrwan(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTask(string memory _description) public onlyOwner {
        tasks.push(Task(_description, false));
        emit TaskCreated(tasks.length - 1, _description);
    }

    function depositFunds() public payable {
        require(msg.value > 0, "Deposit amount should be greater than 0");
        deposit += msg.value;
    }

    function withdrawDepositSafely() public onlyOwner {
        require(deposit > 0, "No funds to withdraw");
        uint256 amount = deposit;
        payable(owner).transfer(amount);
        deposit = 0;
        emit DepositWithdrwan(amount);
    }

    function allTaskCompleted() private view returns (bool) {
        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isCompleted) {
                return false;
            }
        }
        return true;
    }

    function clearTask() private {
        delete tasks;
    }

    function completeTask(uint256 _taskId) public onlyOwner {
        require(_taskId < tasks.length, "Invalid task id");
        require(!tasks[_taskId].isCompleted, "Task is already completed");

        tasks[_taskId].isCompleted = true;
        emit TaskCompleted(_taskId);

        if (allTaskCompleted()) {
            uint256 amount = deposit;
            payable(owner).transfer(amount);
            deposit = 0;
            emit DepositWithdrwan(amount);
            clearTask();
        }
    }

    function getTaskCount() public view returns (uint256) {
        return tasks.length;
    }

    function getDeposit() public view returns (uint256) {
        return deposit;
    }

    function getTask() public view returns (Task[] memory) {
        return tasks;
    }
}
