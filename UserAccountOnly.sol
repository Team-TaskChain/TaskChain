pragma solidity >=0.4.22 <0.7.0;

contract MappedStructsWithIndex {
    enum UserType {Creator, Worker, Arbitrator, Admin}
    enum UserTier {TierOne, TierTwo, TierThree}
    enum AccountStatus {good, restricted}
    uint256 public tasksCompleted;
    address public RootAdmin;
    
    constructor() public {
        RootAdmin = msg.sender;
    }
    
    
    modifier onlyRootAdmin (){
    require(msg.sender == RootAdmin, "Only Rootadmins may perform this function");
            _;
    }
    
    modifier onlyArbitrator(){
        require(userStructs[msg.sender].userType == UserType.Arbitrator, "Only Arbitrators may perform this function");
        _;
    }
    
    modifier goodStatus() {
        require(userStructs[msg.sender].accountStatus == AccountStatus.good, "Your account is not in good standing");
        _;
    }
    
    event NewUserRegistered (address userAddress);
    event UserTierUpgrade (UserTier);

    struct UserAccount {
        bool isUsed;
        string userName;
        UserTier userTier;
        UserType userType;
        uint256 tasksCompleted;
        AccountStatus accountStatus;
    }


    mapping(address => UserAccount) public userStructs;
    address[] public userLists;
    
   


    function isUser(address userAddress) public view returns (string memory userName) {
        return userStructs[userAddress].userName;
    }

    function getUserCount() public view returns (uint256 userCount) {
        return userLists.length;
    }

    function newUser(string memory userName) public returns (uint256 rowNumber) {
        require(userStructs[msg.sender].isUsed != true);
        userStructs[msg.sender].userName = userName;
        userStructs[msg.sender].isUsed = true;
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
   
   function appointArbitrator() public goodStatus returns(bool success) {
       require (userStructs[msg.sender].userTier == UserTier.TierThree, 'You must be a TierThree user to arbitrate');
       userStructs[msg.sender].userType = UserType.Arbitrator;
       return true;
   }
   
   function updateUserComplete(uint _tasksCompleted) public {
       userStructs[msg.sender].tasksCompleted += _tasksCompleted;
   }
   
   function createAdmin(address _address) public onlyRootAdmin {
       userStructs[_address].userType = UserType.Admin;
   }
       
    function demoteAdmin(address _address, uint _Index) public onlyRootAdmin {
        userStructs[_address].userType = UserType(_Index);
    }
   
   
   function restrictAccount(address _address) public {
       require (userStructs[msg.sender].userType == UserType.Admin, "Only Admins may perform this function");
       userStructs[_address].accountStatus = AccountStatus.restricted;
   }
   
   function restoreAccount(address _address) public {
       require (userStructs[msg.sender].userType == UserType.Admin, "Only Admins may perform this function");
       userStructs[_address].accountStatus = AccountStatus.restricted;
       
   }
   
}
   

    
