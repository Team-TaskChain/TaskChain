pragma solidity >=0.4.22 <0.7.0;
import "./HitchensUnorderedAddressSetLib.sol";
import "./HitchensUnorderedKeySetLib.sol";



contract TaskChain {

    using HitchensUnorderedAddressSetLib for HitchensUnorderedAddressSetLib.Set;
    HitchensUnorderedAddressSetLib.Set userSet;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set contractSet;
    
    
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
        newUser("RootAdmin", 0);
        createAdmin(msg.sender);
    }
    
    //modifiers to restrict access to functions
    modifier onlyRootAdmin (){
    require(msg.sender == RootAdmin, "Only Rootadmins may perform this function");
            _;
    }
    
    modifier onlyWorkers(){
        require(userStructs[msg.sender].userType == UserType.Worker, "Only workers may work");
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
    
    modifier onlyOwner(bytes32 key) {
        require(contractStruct[key].ContractOwner ==msg.sender, "only the contract owner may do this!");
        _;
    }
    
    event NewUserRegistered (address indexed _from, string _username, UserType _userType);
    event UserTierUpgrade (address indexed _from, string _success, UserTier _userTier);

    //the base structure for all user accouts. isUsed is to restrict users to one account per address, which helps presever status and rank
    struct UserAccount {        
        string userName;
        UserTier userTier;
        UserType userType;
        uint256 tasksCompleted;
        AccountStatus accountStatus;
        bool isAdmin;
        uint256 accountBalance;
        uint256 accountEscrow;
    }
    
    //stores the address for all useraccounts
    mapping(address => UserAccount) public userStructs;
    UserAccount[] public userAccounts;
    address[] public userLists;    
    
    

    //creates a new user
    function newUser(string memory userName, uint _index) public {
        require(_index==0 || _index==1);
        UserAccount storage w = userStructs[msg.sender];
        userSet.insert(msg.sender);        
        w.userType = UserType(_index);
        w.userName = userName;        
        w.isAdmin = false; 
        w.accountBalance = 0;
        w.accountEscrow =0;
        emit NewUserRegistered(msg.sender, userName, UserType(_index));
           
    }

     function updateUser(address key, string memory _userName, UserType _userType) onlyRootAdmin public {
        require(userSet.exists(key), "Can't update a widget that doesn't exist.");
        UserAccount storage w = userStructs[key];
        w.userName = _userName;        
        w.userType = _userType;               
    }

     function getUser(address key) public view returns(string memory _userName, UserTier _userTier, UserType _userType, uint256 _tasksCompleted, AccountStatus _accountStatus, bool _isAdmin, uint256 _accountBalance, uint256 _accountEscrow) {
        require(userSet.exists(key), "Can't get a widget that doesn't exist.");
        UserAccount storage w = userStructs[key];
        return(w.userName, w.userTier, w.userType, w.tasksCompleted, w.accountStatus, w.isAdmin, w.accountBalance, w.accountEscrow);
    }

    function getUserCount() public view returns(uint count) {
        return userSet.count();
    }

     function getUserIndex(uint index) public view returns(address key) {
        return userSet.keyAtIndex(index);
    }

    
    //enables the uprage of tiers, depending on how many tasks have been completed
   function updateUserTier() public goodStatus returns(string memory _success) {
        address key = msg.sender;
        require(userSet.exists(key), "Can't update a widget that doesn't exist.");
        UserAccount storage w = userStructs[key];
       if (w.tasksCompleted > 50 ) {
           w.userTier =  UserTier.TierThree;
           _success = "TierThree";
       }
       else if (w.tasksCompleted > 10 && w.tasksCompleted<50) {
           w.userTier = UserTier.TierTwo;
           _success = "TierTwo";

       }
       else {
            w.userTier = UserTier.TierOne;
            _success = "TierOne";
       }
      emit UserTierUpgrade(msg.sender, _success, w.userTier);
      return _success;
        }
   event appointedArbitrator(address indexed _from);
   //appoints a new arbitrator, must be tier three to perform this function
   function appointArbitrator() public goodStatus returns(bool success) {
       address key = msg.sender;
       require(userSet.exists(key), "Can't update a widget that doesn't exist.");
       UserAccount storage w = userStructs[key];
       require (w.userTier == UserTier.TierThree, "You must be a TierThree user to arbitrate");
       w.userType = UserType.Arbitrator;
       emit appointedArbitrator(msg.sender);
       return true;
   }
   
   //internal function to test functionality, will be removed before realease
   function updateUserComplete(uint _tasksCompleted, address key) onlyRootAdmin public {
       require(userSet.exists(key), "Can't update a widget that doesn't exist.");
       UserAccount storage w = userStructs[key];
       w.tasksCompleted += _tasksCompleted;
   }
   
   event newAdmin(address indexed _from, address indexed _to);
   event removeAdmin(address indexed _from, address indexed _to);
   event newRestrictedAccount(address indexed _from, address indexed _to);
   event removeRestrictAccount(address indexed _from, address indexed _to);
   
   //apoints new admin
   function createAdmin(address key) public onlyRootAdmin {
       require(userSet.exists(key), "Can't update a widget that doesn't exist.");
       UserAccount storage w = userStructs[key];
       w.isAdmin = true;
       emit newAdmin(msg.sender, key);
   }
   
   
   //removes admin, to prevent malicious users    
    function demoteAdmin(address key) public onlyRootAdmin {       
       require(userSet.exists(key), "Can't update a widget that doesn't exist.");
       UserAccount storage w = userStructs[key];
       w.isAdmin = false;
       emit removeAdmin(msg.sender, key);
    }
   
   //enables the restriction of accounts, for malicious use
   function restrictAccount(address key) onlyAdmin goodStatus public {
       require(userSet.exists(key), "Can't update a widget that doesn't exist.");
       UserAccount storage w = userStructs[key];
         w.accountStatus = AccountStatus.restricted;
         emit newRestrictedAccount(msg.sender, key);
   }

    //restores accounts, based on admin discretion. Timeouts will be added later, for automatic use by user
   function restoreAccount(address key) onlyAdmin goodStatus public {
       require(userSet.exists(key), "Can't update a widget that doesn't exist.");
       UserAccount storage w = userStructs[key];
       w.accountStatus = AccountStatus.restricted;
       emit removeRestrictAccount(msg.sender, key);
       
   }
   

  
  event ContractCreated(address indexed _from, uint256 _value, uint256 _payout, UserTier _usertier);
  event ContractClosed(address indexed _from, uint _bal, bytes32 indexed _contract);
  event workDone(address indexed _from, address indexed _to, uint256 payout);
  
  // defines what tier the contract is. This will correlate to the minimum tier of user required to do work
  
 
  
// based structure for contracts, with quota being the number of times the work will be completed, value being the embedded escrow for the contract, and payout being automatic depeding on value/quota
  struct newContract {
      address ContractOwner;
      string contractName;
      uint256 value;
      uint256 quota;
      uint256 payout;
      UserTier userTier;
      bool activeContract;  
      uint256 balance;      
  }



mapping(address => mapping(bytes32 => bool)) workerPassCheck;
mapping(address => mapping(bytes32 => uint256)) workEscrow;


//stores all contract info. Each address can only have one open contract at the moment
  mapping(bytes32 => newContract) contractStruct;
  
  
  //stores the balance for the contract, seperate from the creators wallet
 
  
  
  //internal function to add a new takscompletion after work is done
  function addTaskComplete() internal {
    userStructs[msg.sender].tasksCompleted+= 1;
  }     

//creates a new contract
function createContract(bytes32 key, string memory _contractName, uint _taskTier, uint256 _quota, uint amount) public onlyCreators goodStatus payable{
    contractSet.insert(key);
    newContract storage w = contractStruct[key];
    uint amountEscrow = amount*10 /100;
    uint contractAmount = amount * 90/100;
    uint contractPayout = contractAmount/_quota;
    w.contractName = _contractName;
    w.ContractOwner = msg.sender;
    w.value = contractAmount;
    w.quota = _quota;
    w.userTier = UserTier(_taskTier);
    userStructs[0xa48F2e0bE8ab5A04A5eB1f86eaD1923f03A207fd].accountBalance+=amountEscrow;
    w.balance += contractAmount;
    w.activeContract = true;
    w.payout = contractPayout;    
    emit ContractCreated(msg.sender, contractAmount, contractPayout, UserTier(_taskTier));
   }

function updateContract(bytes32 key, string memory _contractName) onlyRootAdmin public {
        require(contractSet.exists(key), "Can't update a widget that doesn't exist.");
        newContract storage w = contractStruct[key];
        w.contractName = _contractName;         
    }
function removeContract(bytes32 key) onlyOwner(key) public {
        contractSet.remove(key); // Note that this will fail automatically if the key doesn't exist
        delete contractStruct[key];        
    }

 function getContract(bytes32 key) public view returns(address _ContractOwner, string memory _contractName, uint256 _value, uint256 _quota, uint256 _payout, UserTier _userTier, uint256 _balance) {
        require(contractSet.exists(key), "Can't get a widget that doesn't exist.");
        newContract storage w = contractStruct[key];
        return(w.ContractOwner, w.contractName, w.value, w.quota, w.payout, w.userTier, w.balance);
    }
    function getContractCount() public view returns(uint count) {
        return contractSet.count();
    }
    
    function getContractAtIndex(uint index) public view returns(bytes32 key) {
        return contractSet.keyAtIndex(index);
    }

   mapping(address => bool) public workerPass;

event workDone(address indexed _from, bytes32 indexed _to, uint256 _payout);
function completeWork(bytes32 key) public onlyWorkers payable {
	     require(contractSet.exists(key), "Can't update a widget that doesn't exist.");
         newContract storage w = contractStruct[key];
         require(w.balance > w.payout, "Insufficient Contract Funds");
	     require(w.activeContract!=false, "contract is not open");
         if (userStructs[msg.sender].userTier == UserTier.TierOne){
             require(w.userTier==UserTier.TierOne, "user is tier one, not high enough rank");
         }
         else if(userStructs[msg.sender].userTier == UserTier.TierTwo){
             require(w.userTier!=UserTier.TierThree, "user is teir two, not high enough rank");
         }
	     workEscrow[msg.sender][key]+= w.payout;
	     w.balance -= w.payout;
	     addTaskComplete();
	     workerPassCheck[msg.sender][key] = false;
         emit workDone(msg.sender, key, w.payout);	     
        }

  function reviewWork(bool _passFail, bytes32 key, address _add) onlyOwner(key) onlyCreators public {
        require(workerPassCheck[_add][key]==false, "The worker must not have passed to review");
        require(contractSet.exists(key), "Can't update a widget that doesn't exist.");
        newContract storage w = contractStruct[key];
        require(userSet.exists(_add), "Can't update a widget that doesn't exist.");
        require(w.ContractOwner==msg.sender, "Only the owner can review work!");
        if (_passFail==true){
            workerPassCheck[_add][key]=true;
        } else {
        emit callArbitration(msg.sender, _add, key, _passFail);    
        }
    }
function arbitrateWork(bool _passFail, address _workerAdd, bytes32 key ) onlyArbitrator public payable {
        require(contractSet.exists(key), "Can't update a widget that doesn't exist.");
        newContract storage w = contractStruct[key];
        require(userSet.exists(_workerAdd), "Can't update a widget that doesn't exist.");
        UserAccount storage self = userStructs[msg.sender];
        UserAccount storage root = userStructs[RootAdmin];
        require(workerPassCheck[_workerAdd][key]==false, "The worker must not have passed to arbitrate");
        if (_passFail==true){
            workerPassCheck[_workerAdd][key]=true;
            root.accountBalance-=w.payout;
            w.balance-=2*w.payout;
            self.accountBalance+=2*w.payout;
            emit arbitrationWorking(msg.sender, _workerAdd, key, _passFail);
            }
        else if (_passFail==false) {
            workerPassCheck[_workerAdd][key]=false;
            root.accountBalance -= 2 * w.payout;
            workEscrow[msg.sender][key]-=w.payout;
            self.accountBalance+=2*w.payout;
            w.balance+= w.payout;
            emit arbitrationWorking(msg.sender, _workerAdd, key, _passFail);
        }
    }
 function transferEscrow(bytes32 key) public payable{
        require(workerPassCheck[msg.sender][key]== true, "Your work must be reviewed");
        require(contractSet.exists(key), "Can't update a widget that doesn't exist.");
        UserAccount storage self = userStructs[msg.sender];
        uint256 actBal;
        actBal = workEscrow[msg.sender][key];
        workEscrow[msg.sender][key]-= actBal;
        self.accountBalance+= actBal;
        emit transferEscrowOut(msg.sender, actBal, key);        
    }


function cashOut() public payable {
       uint256 accountBal;
       accountBal= userStructs[msg.sender].accountBalance;
       userStructs[msg.sender].accountBalance -= accountBal;
       msg.sender.transfer(accountBal);
       emit userCashOut(msg.sender, accountBal);
    }
 // closes the contract, and empties wallet back to creator
    function closeContract(bytes32 key) onlyCreators onlyOwner(key) public payable {
        require(contractSet.exists(key), "Can't update a widget that doesn't exist.");
        newContract storage w = contractStruct[key];
        require(msg.sender==w.ContractOwner, "only the owner can close the contract");
        uint256 accountBal;
        accountBal = w.balance;
        accountBal-=accountBal;
        w.activeContract = false;
        msg.sender.transfer(accountBal);
        removeContract(key);
        emit ContractClosed(msg.sender, accountBal, key);
    }

event userCashOut(address indexed _from, uint256 _bal);


event arbitrationWorking(address indexed _from, address indexed _to, bytes32 indexed _contract, bool _arbitrateResult);
event transferEscrowOut(address indexed _from, uint256 _balance, bytes32 key);



  event callArbitration(address indexed _from, address indexed _to, bytes32 indexed _fromKey, bool _passFail);
}
