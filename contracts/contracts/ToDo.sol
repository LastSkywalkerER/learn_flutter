// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ToDoList {
    mapping(address => bytes32[]) public todos;

    function getTodosByAddress(address _address) external view returns (bytes32[] memory) {
        return todos[_address];
    }

    function addToDo(bytes32 _todo) external {
        todos[msg.sender].push(_todo);
    }

    function removeToDo(uint256 _index) external {
        require(todos[msg.sender].length > _index, "No such ToDo");

        todos[msg.sender][_index] = todos[msg.sender][todos[msg.sender].length - 1];
        todos[msg.sender].pop();
    }
}