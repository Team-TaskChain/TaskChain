pragma solidity >=0.4.22 <0.7.0;

contract MappedStructsWithIndex {
    enum UserType {Creator, Worker, Abitrator}
    enum UserTier {TierOne, TierTwo, TierThree}
    enum AccountStatus {good, restricted}
    uint256 public tasksCompleted;
    bool isOpen = true;

    struct UserAccount {
        bool isOpen;
        string userName;
        UserTier userTier;
        UserType userType;
        uint256 tasksCompleted;
        AccountStatus accountStatus;
    }

    struct EntityStruct {
        uint256 entityData;
        bool isEntity;
    }

    mapping(address => UserAccount) public userStructs;
    address[] public userLists;

    function isUser(address userAddress) public view returns (string userName) {
        return userStructs[userAddress].userName;
    }

    function getUserCount() public view returns (uint256 userCount) {
        return userLists.length;
    }

    function newUser(string userName) public returns (uint256 rowNumber) {
        require(!userStructs[msg.sender].isOpen);
        userStructs[msg.sender].userName = userName;
        userStructs[msg.sender].isOpen = false;
        return userLists.push(msg.sender) - 1;
    }

    /*
  function newEntity(address entityAddress, uint entityData) public returns(uint rowNumber) {
    if(isEntity(entityAddress)) revert();
    entityStructs[entityAddress].entityData = entityData;
    entityStructs[entityAddress].isEntity = true;
    return entityList.push(entityAddress) - 1;
  

  function updateEntity(address entityAddress, uint entityData) public returns(bool success) {
    if(!isEntity(entityAddress)) revert();
    entityStructs[entityAddress].entityData    = entityData;
    return true
    */

}
