pragma solidity >=0.4.22 <0.7.0;


contract TaskCreate {
    
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
    
    modifier onlyWorkers(){
        require(userStructs[msg.sender].userType == UserType.Worker);
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
    
    modifier onlyAdmin() {
        require(userStructs[msg.sender].isAdmin==true, "You must be an admin to use this feature");
        _;
    }
    
    event NewUserRegistered (address indexed _from, string _username, UserType _userType);
    event UserTierUpgrade (address indexed _from, string _success);

    //the base structure for all user accouts. isUsed is to restrict users to one account per address, which helps presever status and rank
    struct UserAccount {
        bool isUsed;
        string userName;
        UserTier userTier;
        UserType userType;
        uint256 tasksCompleted;
        AccountStatus accountStatus;
        bool isAdmin;
    }
    
    //stores the address for all useraccounts
    mapping(address => UserAccount) public userStructs;
    UserAccount[] public userAccounts;
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
    function newUser(string memory userName, uint _index) public returns (uint256 rowNumber) {
        require(userStructs[msg.sender].isUsed != true);
        require(_index==0 || _index==1);
        userStructs[msg.sender].userType = UserType(_index);
        userStructs[msg.sender].userName = userName;
        userStructs[msg.sender].isUsed = true;
        userStructs[msg.sender].isAdmin = false; 
        emit NewUserRegistered(msg.sender, userName, UserType(_index));
        return userLists.push(msg.sender) - 1;
      
    }
    
    //enables the uprage of tiers, depending on how many tasks have been completed
   function updateUserTier() public goodStatus returns(string memory _success) {
       if (userStructs[msg.sender].tasksCompleted > 50 ) {
           userStructs[msg.sender].userTier =  UserTier.TierThree;
           _success = "TierThree";
       }
       else if (userStructs[msg.sender].tasksCompleted > 10 && userStructs[msg.sender].tasksCompleted<50) {
           userStructs[msg.sender].userTier = UserTier.TierTwo;
           _success = "TierTwo";

       }
       else {
            userStructs[msg.sender].userTier = UserTier.TierOne;
            _success = "TierOne";
       }
      emit UserTierUpgrade(msg.sender, _success);
      return _success;
        }
   event appointedArbitrator(address indexed _from);
   //appoints a new arbitrator, must be tier three to perform this function
   function appointArbitrator() public goodStatus returns(bool success) {
       require (userStructs[msg.sender].userTier == UserTier.TierThree, 'You must be a TierThree user to arbitrate');
       userStructs[msg.sender].userType = UserType.Arbitrator;
       emit appointedArbitrator(msg.sender);
       return true;
   }
   
   //internal function to test functionality, will be removed before realease
   function updateUserComplete(uint _tasksCompleted) public {
       userStructs[msg.sender].tasksCompleted += _tasksCompleted;
   }
   
   event newAdmin(address indexed _from, address indexed _to);
   event removeAdmin(address indexed _from, address indexed _to);
   event newRestrictedAccount(address indexed _from, address indexed _to);
   event removeRestrictAccount(address indexed _from, address indexed _to);
   
   //apoints new admin
   function createAdmin(address _address) public onlyRootAdmin {
       userStructs[_address].isAdmin = true;
       emit newAdmin(msg.sender, _address);
   }
   
   
   //removes admin, to prevent malicious users    
    function demoteAdmin(address _address) public onlyRootAdmin {
        userStructs[_address].isAdmin = false;
        emit removeAdmin(msg.sender, _address);
    }
   
   //enables the restriction of accounts, for malicious use
   function restrictAccount(address _address) onlyAdmin public {
         userStructs[_address].accountStatus = AccountStatus.restricted;
         emit newRestrictedAccount(msg.sender, _address);
   }

    //restores accounts, based on admin discretion. Timeouts will be added later, for automatic use by user
   function restoreAccount(address _address) onlyAdmin public {
       userStructs[_address].accountStatus = AccountStatus.restricted;
       emit removeRestrictAccount(msg.sender, _address);
       
   }
   

  
  //stores variables for contract in and out
  uint public conntractStartTime;
  uint public contractEndTime;
  
  
  
  event ContractCreated(address indexed _from, uint256 _value, uint256 _payout, UserTier _usertier);
  event ContractClosed(address indexed _from, uint _bal);
  event workDone(address indexed _from, address indexed _to, uint256 payout);
  
  // defines what tier the contract is. This will correlate to the minimum tier of user required to do work
  enum ContractTier {cTierOne, cTierTwo, cTierThree}
  
 
  
// based structure for contracts, with quota being the number of times the work will be completed, value being the embedded escrow for the contract, and payout being automatic depeding on value/quota
  struct newContract {
      address ContractOwner;
      uint256 value;
      uint256 quota;
      uint256 payout;
      UserTier userTier;
      bool activeContract;
      bool isCreated;
  }

//stores all contract info. Each address can only have one open contract at the moment
  mapping(address => newContract) contractStruct;
  address[] public contractLists;


   function isEntity(address entityAddress) public view returns(bool isIndeed) {
      return contractStruct[entityAddress].isCreated;
  }

  function getEntityCount() public view returns(uint entityCount) {
    return contractLists.length;
  }

  //stores the balance for the contract, seperate from the creators wallet
  mapping(address => uint) public contractBalance;
  
  
  //internal function to add a new takscompletion after work is done
  function addTaskComplete() internal {
    userStructs[msg.sender].tasksCompleted+= 1;
  }
  
  
  function checkContractStruct(address contractAddress) public view returns (address ContractOwner, uint256 value, uint256 quota, uint256 payout, uint256 currentBalance, bool Open, UserTier _userTier) {
    ContractOwner = contractStruct[contractAddress].ContractOwner;
    value = contractStruct[contractAddress].value;
    quota = contractStruct[contractAddress].quota;
    payout = contractStruct[contractAddress].payout;
    currentBalance = contractBalance[contractAddress];
    Open = contractStruct[contractAddress].activeContract;
    _userTier = contractStruct[contractAddress].userTier;
    return(ContractOwner, value, quota, payout, currentBalance, Open, _userTier);
  }
    

//creates a new contract
function createContract(uint _taskTier, uint256 _quota, uint amount) public onlyCreators payable returns(uint rowNumber)  {
    uint amountEscrow = amount*5 /100;
    uint contractAmount = amount * 95/100;
    uint contractPayout = contractAmount/_quota;
    contractStruct[msg.sender].ContractOwner = msg.sender;
    contractStruct[msg.sender].value = contractAmount;
    contractStruct[msg.sender].quota = _quota;
    contractStruct[msg.sender].userTier = UserTier(_taskTier);
    reserveWallet[RootAdmin]+=amountEscrow;
    contractBalance[msg.sender] += contractAmount;
    contractStruct[msg.sender].activeContract = true;
    contractStruct[msg.sender].payout = contractPayout;  
    contractStruct[msg.sender].isCreated = true;
    emit ContractCreated(msg.sender, contractAmount, contractPayout, UserTier(_taskTier));
    return contractLists.push(msg.sender) - 1;
}
  
  event callArbitration(address indexed _from, address indexed _to, bool _passFail);
  
    //mapping for the worker wallet to store funds
   mapping(address => uint) public workerEscrow;
   mapping(address => uint) public workerWallet; 
   mapping(address => bool) public workerPass;
   mapping(address => bool) public requiresArbitration;
   mapping(address => uint) public arbitrationWallet;
   mapping(address => uint) public reserveWallet;
   
    //enables the completion of work: TODO add arbitration requirement	   
	 function completeWork(address _add) public onlyWorkers payable {
	     require(contractBalance[_add] > contractStruct[_add].payout, "Insufficient Contract Funds");
	     require(contractStruct[_add].activeContract!=false, "contract is not open");
	     require(msg.sender != contractStruct[_add].ContractOwner, "you can't work on your own stuff");
	     require(userStructs[msg.sender].userTier==contractStruct[_add].userTier, "You Have Insufficient Rank");
	     workerEscrow[msg.sender]+= contractStruct[_add].payout;
	     contractBalance[_add] -= contractStruct[_add].payout;
	     addTaskComplete();
	     workerPass[msg.sender] = false;
	     emit workDone(_add, msg.sender, contractStruct[_add].payout);
        }
        
    function reviewWork(bool _passFail, address _add) onlyCreators public {
        require(workerPass[_add]==false, "The worker must not have passed to review");
        require(contractStruct[msg.sender].ContractOwner==msg.sender, "Only the owner can review work!");
        if (_passFail==true){
            workerPass[_add]=true;
        } else {
        emit callArbitration(msg.sender, _add, _passFail);    
        }
    }
    
    event arbitrationWorking(address indexed _from, address indexed _to, address indexed _contract, bool _arbitrateResult);
    event transferEscrowOut(address indexed _from, uint256 _balance);
    
    //Controls arbitration functions
    function arbitrateWork(bool _passFail, address _workerAdd, address _contractAdd ) onlyArbitrator public payable {
        require(workerPass[_workerAdd]==false, "The worker must not have passed to arbitrate");
        if (_passFail==true){
            workerPass[_workerAdd]=true;
            reserveWallet[RootAdmin]-=contractStruct[_contractAdd].payout;
            contractBalance[_contractAdd]-=2*contractStruct[_contractAdd].payout;
            workerEscrow[msg.sender]+=contractStruct[_contractAdd].payout;
            arbitrationWallet[msg.sender]+=2*contractStruct[_contractAdd].payout;
            emit arbitrationWorking(msg.sender, _workerAdd, _contractAdd, _passFail);
            }
        else if (_passFail==false) {
            workerPass[_workerAdd]=false;
            reserveWallet[RootAdmin]-= 2 * contractStruct[_contractAdd].payout;
            workerEscrow[_workerAdd]-=contractStruct[_contractAdd].payout;
            arbitrationWallet[msg.sender]+=2*contractStruct[_contractAdd].payout;
            contractBalance[_contractAdd]+= contractStruct[_contractAdd].payout;
            emit arbitrationWorking(msg.sender, _workerAdd, _contractAdd, _passFail);
        }
    }
        
    function transferEscrow() public onlyWorkers payable{
        require(workerPass[msg.sender]== true, 'Your work must be reviewed');
        uint256 actBal;
        actBal = workerEscrow[msg.sender];
        workerEscrow[msg.sender]-= actBal;
        workerWallet[msg.sender]+= actBal;
        emit transferEscrowOut(msg.sender, actBal);
        
    }
    event cashOut(address indexed _from, uint256 _bal);
    
    //cashes out worker wallet to worker: TODO add arbitration restrictions
    function workCashOut() onlyWorkers public payable {
       uint256 accountBal;
       accountBal= workerWallet[msg.sender];
       workerWallet[msg.sender]-= accountBal;
       msg.sender.transfer(accountBal);
       emit cashOut(msg.sender, accountBal);
    }
    
    function arbitratorCashOut() public onlyArbitrator payable {
        uint256 accountBal;
        accountBal = arbitrationWallet[msg.sender];
        arbitrationWallet[msg.sender]-=accountBal;
        msg.sender.transfer(accountBal);
        emit cashOut(msg.sender, accountBal);
    }
    // closes the contract, and empties wallet back to creator
    function closeContract() onlyCreators public payable {
        require(msg.sender==contractStruct[msg.sender].ContractOwner, "only the owner can close the contract");
        uint256 accountBal;
        accountBal= contractBalance[msg.sender];
        contractBalance[msg.sender]-=accountBal;
        contractStruct[msg.sender].activeContract = false;
        msg.sender.transfer(accountBal);
        emit ContractClosed(msg.sender, accountBal);
    }

    //checks current balance for the contract wallet
    function checkContractBal(address _address) view public returns (uint _currentBal) {
        _currentBal = contractBalance[_address];
        return _currentBal;
    }
}
