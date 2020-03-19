pragma solidity >=0.4.22 <0.7.0;

contract MappedStructsWithIndex {
    
    //defines userType: Creators add tasks, Workers complete tasks, Arbitrators resolve disputes, Admins perform administrative and punitive functions
    enum UserType {Creator, Worker, Arbitrator, Admin}
    //defines userTiers, with TierOne being a new user, and TierThree being the highest, veteran users
    enum UserTier {TierOne, TierTwo, TierThree}
    // enables account restricitons and punitive measures
    enum AccountStatus {good, restricted}
    //defines the master RootAdmin, who can create new admins
    address public RootAdmin;

    //defines the rootadmin as the creator of the contract
    constructor() public {
        RootAdmin = msg.sender;
    }
    
    //modifiers to restrict access to functions
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

    //the base structure for all user accouts. isUsed is to restrict users to one account per address, which helps presever status and rank
    struct UserAccount {
        bool isUsed;
        string userName;
        UserTier userTier;
        UserType userType;
        uint256 tasksCompleted;
        AccountStatus accountStatus;
    }
    
    //stores the address for all useraccounts
    mapping(address => UserAccount) public userStructs;
    address[] public userLists;
    
    //retrieves user info
    function getUser(address n) public view returns(bool, string memory, UserTier, UserType, uint256, AccountStatus){
        return(userStructs[n].isUsed, userStructs[n].userName, userStructs[n].userTier, userStructs[n].userType, userStructs[n].tasksCompleted, userStructs[n].accountStatus);
    }
    
    //retrieves only username
    function isUser(address userAddress) public view returns (string memory userName) {
        return userStructs[userAddress].userName;
    }
    
    //retrieves the current amount of users
    function getUserCount() public view returns (uint256 userCount) {
        return userLists.length;
    }
    
    //creates a new user
    function newUser(string memory userName) public returns (uint256 rowNumber) {
        require(userStructs[msg.sender].isUsed != true);
        userStructs[msg.sender].userName = userName;
        userStructs[msg.sender].isUsed = true;
        return userLists.push(msg.sender) - 1;
    }
    
    //enables the uprage of tiers, depending on how many tasks have been completed
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
   
   //appoints a new arbitrator, must be tier three to perform this function
   function appointArbitrator() public goodStatus returns(bool success) {
       require (userStructs[msg.sender].userTier == UserTier.TierThree, 'You must be a TierThree user to arbitrate');
       userStructs[msg.sender].userType = UserType.Arbitrator;
       return true;
   }
   
   //internal function to test functionality, will be removed before realease
   function updateUserComplete(uint _tasksCompleted) public {
       userStructs[msg.sender].tasksCompleted += _tasksCompleted;
   }
   
   //apoints new admin
   function createAdmin(address _address) public onlyRootAdmin {
       userStructs[_address].userType = UserType.Admin;
   }
   
   //removes admin, to prevent malicious users    
    function demoteAdmin(address _address, uint _Index) public onlyRootAdmin {
        userStructs[_address].userType = UserType(_Index);
    }
   
   //enables the restriction of accounts, for malicious use
   function restrictAccount(address _address) public {
       require (userStructs[msg.sender].userType == UserType.Admin, "Only Admins may perform this function");
       userStructs[_address].accountStatus = AccountStatus.restricted;
   }

    //restores accounts, based on admin discretion. Timeouts will be added later, for automatic use by user
   function restoreAccount(address _address) public {
       require (userStructs[msg.sender].userType == UserType.Admin, "Only Admins may perform this function");
       userStructs[_address].accountStatus = AccountStatus.restricted;
       
   }
   
}

contract TaskCreateTest is MappedStructsWithIndex {
	    
	    
  
  
  //stores variables for contract in and out
  uint public conntractStartTime;
  uint public contractEndTime;
  
  
  
  event ContractCreated(address Creator, uint value);
  event ContractClosed(address Creator, uint payout);
  event workDone(address Worker, uint balanceContract);
  
  // defines what tier the contract is. This will correlate to the minimum tier of user required to do work
  enum ContractTier {cTierOne, cTierTwo, cTierThree}
  
// based structure for contracts, with quota being the number of times the work will be completed, value being the embedded escrow for the contract, and payout being automatic depeding on value/quota
  struct newContract {
      address ContractOwner;
      uint256 value;
      uint256 quota;
      uint256 payout;
      ContractTier contractTier;
      bool activeContract;
  }

//stores all contract info. Each address can only have one open contract at the moment
  mapping(address => newContract) contractStruct;
  address[] public contractLists;
  //stores the balance for the contract, seperate from the creators wallet
  mapping(address => uint) public contractBalance;
  
  //internal function to add a new takscompletion after work is done
  function addTaskComplete() internal {
    userStructs[msg.sender].tasksCompleted+= 1;
  }

//creates a new contract
function createContract(uint _taskTier, uint256 _quota, uint256 amount) public payable {
    contractStruct[msg.sender].ContractOwner = msg.sender;
    contractStruct[msg.sender].value = amount;
    contractStruct[msg.sender].quota = _quota;
    contractStruct[msg.sender].contractTier = ContractTier(_taskTier);
    contractBalance[msg.sender] += amount;
    contractStruct[msg.sender].activeContract = true;
    contractStruct[msg.sender].payout = amount/_quota;
    require(msg.value == amount);
}
  
  
    //mapping for the worker wallet to store funds
   mapping(address => uint) public workerWallet; 
   
   
    //enables the completion of work: TODO add arbitration requirement	   
	 function completeWork(address _add) public payable {
	     require(contractBalance[_add] > contractStruct[_add].payout, 'Insufficient Contract Funds');
	     require(contractStruct[_add].activeContract!=false, "contract is not open");
	     require(msg.sender != contractStruct[_add].ContractOwner, "you can't work on your own stuff");
	     workerWallet[msg.sender]+= contractStruct[_add].payout;
	     contractBalance[_add] -= contractStruct[_add].payout;
	     addTaskComplete();
	     emit workDone(msg.sender, contractBalance[_add]);
        }
    //cashes out worker wallet to worker: TODO add arbitration restrictions
    function workCashOut() public payable {
       uint256 accountBal;
       accountBal= workerWallet[msg.sender];
       workerWallet[msg.sender]-= accountBal;
       msg.sender.transfer(accountBal);
    }
    
    // closes the contract, and empties wallet back to creator
    function closeContract() public payable {
        require(msg.sender==contractStruct[msg.sender].ContractOwner, "only the owner can close the contract");
        uint256 accountBal;
        accountBal= contractBalance[msg.sender];
        contractBalance[msg.sender]-=accountBal;
        contractStruct[msg.sender].activeContract = false;
        msg.sender.transfer(accountBal);
    }

    //checks current balance for the contract wallet
    function checkContractBal() view public returns (uint) {
        return contractBalance[msg.sender];
    }
}

