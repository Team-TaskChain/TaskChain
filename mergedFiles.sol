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
    modifier onlyCreators(){
        require(userStructs[msg.sender].userType == UserType.Creator, "Only Creators may create");
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
    
    
    function getUser(address n) public view returns(bool, string memory, UserTier, UserType, uint256, AccountStatus){
        return(userStructs[n].isUsed, userStructs[n].userName, userStructs[n].userTier, userStructs[n].userType, userStructs[n].tasksCompleted, userStructs[n].accountStatus);
    }
    
    
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

contract TaskCreateTest is MappedStructsWithIndex {
	    
	    
  address owner;
  uint public value;
  uint public quota;
  uint public payout;
  address payable public ContractOwner;
  address payable public workerPerson;
  uint accountBal;
  
  
  uint public conntractStartTime;
  uint public contractEndTime;
  
  
  mapping(address => uint) workPayed;
  
  bool ended;
 

  event ContractCreated(address Creator, uint value);
  event ContractClosed(address Creator, uint payout);
  event workDone(address Worker, uint balanceContract);
  
  enum ContractTier {cTierOne, cTierTwo, cTierThree}
  
  
  struct newContract {
      address Owner;
      uint256 value;
      uint256 quota;
      uint256 payout;
      ContractTier contractTier;
      bool activeContract;
  }

  mapping(address => newContract) contractStruct;
  address[] public contractLists;
  mapping(address => uint) public contractBalance;

function createContract(uint _taskTier, uint256 _quota, uint256 amount) public payable {
    contractStruct[msg.sender].Owner = msg.sender;
    contractStruct[msg.sender].value = amount;
    contractStruct[msg.sender].quota = _quota;
    contractStruct[msg.sender].contractTier = ContractTier(_taskTier);
    contractBalance[msg.sender] += amount;
    contractStruct[msg.sender].activeContract = true;
    require(msg.value == amount);
}
  
  
  
   mapping(address => uint) public workerWallet; 
	   
	 function completeWork() public payable {
	     require(contractBalance[ContractOwner]> payout, 'Insufficient Contract Funds');
	     require(ended!=true, "contract is not open");
	     require(msg.sender != ContractOwner, "you can't work on your own stuff");
	     workerWallet[msg.sender]+= payout;
	     contractBalance[ContractOwner] -= payout;
	     emit workDone(msg.sender, contractBalance[ContractOwner]);
        }
        
    function workCashOut() public payable {
       accountBal= workerWallet[msg.sender];
       workerWallet[msg.sender]-= accountBal;
       msg.sender.transfer(accountBal);
    }
    
    function closeContract() public payable {
        require(msg.sender==ContractOwner, "only the owner can close the contract");
        accountBal= contractBalance[msg.sender];
        contractBalance[msg.sender]-=accountBal;
        ended = true;
        msg.sender.transfer(accountBal);
    }
    
    function checkContractBal() view public returns (uint) {
        return contractBalance[ContractOwner];
    }
}

