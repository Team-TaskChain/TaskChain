pragma solidity >=0.4.22 <0.7.0;

contract MappedStructsWithIndex {
    enum UserType {Creator, Worker}
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
        bool isArbitrator;
        
    }

    struct EntityStruct {
        uint256 entityData;
        bool isEntity;
    }

    mapping(address => UserAccount) public userStructs;
    address[] public userLists;

    function isUser(address userAddress) public view returns (string memory userName) {
        return userStructs[userAddress].userName;
    }

    function getUserCount() public view returns (uint256 userCount) {
        return userLists.length;
    }

    function newUser(string memory userName, UserType _UserType) public returns (uint256 rowNumber) {
        require (userStructs[msg.sender].isOpen == false);
        userStructs[msg.sender].userName = userName;
        userStructs[msg.sender].isOpen = true;
        userStructs[msg.sender].userType = _UserType;
        userStructs[msg.sender].isArbitrator == false;
        return userLists.push(msg.sender) - 1;
    
    }
    
   function updateUserTier() public returns(bool success) {
       if (userStructs[msg.sender].tasksCompleted > 50 ) {
           userStructs[msg.sender].userTier =  UserTier.TierThree;
       }
       else if (userStructs[msg.sender].tasksCompleted > 10 && userStructs[msg.sender].tasksCompleted<50) {
           userStructs[msg.sender].userTier = UserTier.TierTwo;
       }
       else {
            userStructs[msg.sender].userTier = UserTier.TierOne;
       }
      return true;
        }
   
   function appointArbitrator() public {
       require (userStructs[msg.sender].userTier == UserTier.TierThree, 'You must be a TierThree user to arbitrate');
       userStructs[msg.sender].isArbitrator = true;
   }
   
   function updateUserComlete(uint _tasksCompleted) public {
       userStructs[msg.sender].tasksCompleted += _tasksCompleted;
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
