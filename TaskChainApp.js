// The object 'Contracts' will be injected here, which contains all data for all contracts, keyed on contract name:
// Contracts['HelloWorld'] = {
//  abi: [],
//  address: "0x..",
//  endpoint: "http://...."
// }

// Create an instance of the smart contract, passing it as a property, 
// which allows web3js to interact with it.
function TaskCreate(Contract) {
    this.web3 = null;
    this.instance = null;
    this.Contract = Contract;
    console.log("LOAD Success");
}

// Initialize the `Coin` object and create an instance of the web3js library, 
TaskCreate.prototype.init = function() {
    // The initialization function defines the interface for the contract using 
    // the web3js contract object and then defines the address of the instance 
    // of the contract for the `Coin` object.

    // Create a new Web3 instance using either the Metamask provider
    // or an independent provider created as the endpoint configured for the contract.
    this.web3 = new Web3(
        (window.web3 && window.web3.currentProvider) ||
        new Web3.providers.HttpProvider(this.Contract.endpoint));

    // Create the contract interface using the ABI provided in the configuration.
    var contract_interface = this.web3.eth.contract(this.Contract.abi);

    // Create the contract instance for the specific address provided in the configuration.
    this.instance = contract_interface.at(this.Contract.address);
};



// Send Tokens to another address when the "send" button is clicked
TaskCreate.prototype.createNewUser = function() {
    var that = this;

    // Get input values for address and amount

    //var e = document.getElementById("userType");
    //var userType = e.options[e.selectedIndex].value;
    var userName = $("#userName").val();
    var userType = $("#userType").val();
    console.log("Username:", userName);
	console.log("Usertype:", userType);

    

    // Transfer amount to other address
    // Use the public mint function from the smart contract
    this.instance.newUser(userName, userType, { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 }, 
        // If there's an error, log it
        function(error, txHash) {
            if(error) {
                console.log("error1", error);
            }
            // If success then wait for confirmation of transaction
            // with utility function and clear form values while waiting
            else {
                that.waitForReceipt(txHash, function(receipt) {
                    if(receipt.status) {
                        $("#userName").val("");                        
                    }
                    else {
                        console.log("error in user");
                    }
                });
            }
        }
    )
}

// Waits for receipt of transaction
TaskCreate.prototype.waitForReceipt = function(hash, cb) {
    var that = this;

    // Checks for transaction receipt using web3 library method
    this.web3.eth.getTransactionReceipt(hash, function(err, receipt) {
        if (err) {
            console.log("Transaciton Receipt Error");
            error(err);
        }
        if (receipt !== null) {
            // Transaction went through
            if (cb) {
                console.log("reciept1");
                cb(receipt);
                console.log("reciept2");

            }
        } else {
            // Try again in 2 second
            console.log("reciept2");
            window.setTimeout(function() {
                that.waitForReceipt(hash, cb);
            }, 2000);
        }
    });
}
TaskCreate.prototype.isUser = function(hash, cb) {
    var that = this;

    // Get input values, the address to check balance of
    var userAddress = $("#userCheckAddress").val();
    console.log(userAddress);

  
    

    // Check the balance from the address passed and output the value 
    this.getBalance(userAddress, function(error, userStruct) {
        if(error) {
            console.log("UserCreate Erorr", error)
        }
        else {
            console.log(userStruct);  
                          
        }
    })
}


TaskCreate.prototype.getBalance = function(userAddress, cb) {
    this.instance.userStructs(userAddress, function(error, result) {
        cb(error, result);
    })
}
// Check if it has the basic requirements of an address
function isValidAddress(address) {
    return /^(0x)?[0-9a-f]{40}$/i.test(address);
}

// Basic validation of amount. Bigger than 0 and typeof number
function isValidAmount(amount) {
    return amount > 0 && typeof Number(amount) == 'number';    
}

// Bind functions to the buttons defined in app.html
TaskCreate.prototype.bindButtons = function() {
    var that = this;

    $(document).on("click", "#createUser", function() {
        console.log('usertryClick')
        that.createNewUser();
        console.log('UserClick')
    });

    $(document).on("click", "#getUserCountBtn", function() {
        console.log('usertryClick')
        that.isUser();
        console.log('UserClick')
    });
  
}

// Create the instance of the `Coin` object 
TaskCreate.prototype.onReady = function() {
    this.bindButtons();
    this.init();
};

if(typeof(Contracts) === "undefined") var Contracts={ TaskCreate: { abi: [] }};
var task = new TaskCreate(Contracts['TaskCreate']);

$(document).ready(function() {
    task.onReady();
});
