pragma solidity >0.4.23 <0.7.0;

contract TaskCreateTest {
	    
  address owner;
  uint public value;
  uint public balance;
  uint public quota;
  uint public payout;
  address payable public ContractOwner;
  address payable public worker;
  
  uint public conntractStartTime;
  uint public contractEndTime;
  
 
  mapping(address => uint) workPayed;
  
  bool ended;
  
  event ContractCreated(address Creator, uint value);
  event ContractClosed(address Creator, uint payout);
  event workDone(address Worker, uint balanceContract);
  
  mapping(address => uint) public contractBalance;
  
    constructor(uint _quota) public payable{
        ContractOwner = msg.sender;
        value = msg.value;
        contractBalance[msg.sender] = msg.value;
        quota = _quota;
        payout = msg.value/_quota;
        emit ContractCreated(msg.sender, msg.value);
         }
    
	 
	 mapping(address => uint) public workerWallet; 
	   
	 function completeWork() public payable {
	     require(contractBalance[ContractOwner]> payout);
	     workerWallet[msg.sender]+= payout;
	     contractBalance[ContractOwner] -= payout;
}
}

/* OLD CODE
pragma solidity >=0.4.22 <0.7.0;

contract TaskCreate {
    uint public value;
    uint public payout;
    uint public quota;
    address payable public Creator;
    address payable public Worker;

    enum State { Created, Locked, Release, Inactive }
    // The state variable has a default value of the first member, `State.created`
    State public state;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyBuyer() {
        require(
            msg.sender == Worker,
            "Only Worker can call this."
        );
        _;
    }

    modifier onlySeller() {
        require(
            msg.sender == Creator,
            "Only creator can call this."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    // Ensure that `msg.value` is an even number.
    // Division will truncate if it is an odd number.
    // Check via multiplication that it wasn't an odd number.
    constructor(uint _quota) public payable {
        Creator = msg.sender;
        value = msg.value;
        quota = _quota;
        payout = value/quota
        require(value>0 && quota>0);
    }

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    function abort()
        public
        onlySeller
        inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        // We use transfer here directly. It is
        // reentrancy-safe, because it is the
        // last call in this function and we
        // already changed the state.
        Creator.transfer(address(this).balance);
    }

    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * value` ether.
    /// The ether will be locked until confirmReceived
    /// is called.
    function confirmPurchase()
        public
        inState(State.Created)
        condition(msg.value == (2 * value))
        payable
    {
        emit PurchaseConfirmed();
        Worker = msg.sender;
        state = State.Locked;
    }

    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    function confirmReceived()
        public
        onlyBuyer
        inState(State.Locked)
    {
        emit ItemReceived();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Release;

        Worker.transfer(value);
    }

    /// This function refunds the seller, i.e.
    /// pays back the locked funds of the seller.
    function refundSeller()
        public
        onlySeller
        inState(State.Release)
    {
        emit SellerRefunded();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Inactive;

        Creator.transfer(3 * value);
    }
}
*/
