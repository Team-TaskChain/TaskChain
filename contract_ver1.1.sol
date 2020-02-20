pragma solidity >=0.5.0 <0.7.0;

contract TaskTask {
    // defines user account Types
    enum AccountType {Owner, Arbitor, Worker, Creator}
    // defines user tiers, in order
    enum UserTier {One, Two, Three}

    //creates accountCount to track number of user accounts
    uint256 public accountCount;

    address owner;
    // defines messaging event
    event Sent(address from, address to, uint256 amount);
    // creates mapping for balances. need to tie to accoutns
    mapping(address => uint256) public balances;

    // creates initial wallet. May be unecessary at this point
    constructor(address payable _wallet) public {
        wallet = _wallet;
        owner = msg.sender;
    }

    // basic structure for user accounts TODO: add user tiers, add user account type
    struct UserAccount {
        string Username;
        uint256 Rating;
        uint256 userFunds;
    }

    // basic structure for work contracts
    struct TaskWork {
        bool isOpen;
        string taskName;
        uint256 escrow;
        uint256 payout;
        uint256 openTime;
        uint256 closeTime;
        uint256 usersFinished;
    }

    // creates a list of all work currently on record
    TaskWork[] taskWork;

    // creates mapping to track work to specific acocunt, index specific account ownership
    mapping(uint256 => address) public TaskWorkIndexToOwner;
    mapping(uint256 => UserAccount) public accounts;

    function buyToken() public payable {
        balances[msg.sender] += 1;
        wallet.transfer(msg.value);
    }

    address payable wallet;

    // Review for needed extra functions, needs to integrate with standard DB for username/password checks
    function addUserAccount(
        string memory _Username,
        uint256 _Rating,
        uint256 _userFunds
    ) public {
        accountCount += 1;
        accounts[accountCount] = UserAccount(_Username, _Rating, _userFunds);

    }

    /*   basic send/recive coins. Needs the following
1) Update so that amount is automatically sent from the escrow of TaskWork based on payout.
2) Upated to handle accuracy checks for task completion
3) Needs review/reject work from PAYER account
4) Update for arbitration necessity*/
    function send(address receiver, uint256 amount) public {
        // The sender must have enough coins to send
        require(amount <= balances[msg.sender], "Insufficient balance.");
        // Adjust balances
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        // Emit event defined earlier
        emit Sent(msg.sender, receiver, amount);
    }
}
