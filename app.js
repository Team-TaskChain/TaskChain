// The object 'Contracts' will be injected here, which contains all data for all contracts, keyed on contract name:
// Contracts['MyContract'] = {
//  abi: [],
//  address: "0x..",
//  endpoint: "http://...."
// }

function TaskCreate(Contract) {
    this.web3 = null;
    this.instance = null;
    this.Contract = Contract;
}

TaskCreate.prototype.onReady = function() {
    this.init(function () {
        $('#message').append("DApp loaded successfully.");
    });
}

TaskCreate.prototype.init = function(cb) {
    // We create a new Web3 instance using either the Metamask provider
    // or an independent provider created towards the endpoint configured for the contract.
    this.web3 = new Web3(
        (window.web3 && window.web3.currentProvider) ||
        new Web3.providers.HttpProvider(this.Contract.endpoint));

    // Create the contract interface using the ABI provided in the configuration.
    var contract_interface = this.web3.eth.contract(this.Contract.abi);

    // Create the contract instance for the specific address provided in the configuration.
    this.instance = contract_interface.at(this.Contract.address);

    cb();
}

TaskCreate.prototype.createUser() = function() {
	var that = this;
	
	var userName = $("#userName").val();
	var _index = $("#userType").val();
	console.log(userName);
	console.log(_index);
	
	this.instance.newUser(userName, _index, { from: window.web3.eth.accounts[0], gas: 100000, gasPrice: 100000, gasLimit: 100000 },
	
		function(error, txhash) {
			if(error) {
				console.log(error);
			}
			else {
				that.waitForReceipt(txHash, function(receipt){
					if(receipt.status){
						$("#userName").val();
						$("#userType").val();
					}
					else {
						console.log("error");
					}
				}
			}
		}
		
		
		
		
)}
	
Coin.prototype.waitForReceipt = function(hash, cb) {
    var that = this;

    // Checks for transaction receipt using web3 library method
    this.web3.eth.getTransactionReceipt(hash, function(err, receipt) {
        if (err) {
            error(err);
        }
        if (receipt !== null) {
            // Transaction went through
            if (cb) {
                cb(receipt);
            }
        } else {
            // Try again in 2 second
            window.setTimeout(function() {
                that.waitForReceipt(hash, cb);
            }, 2000);
        }
    });
}

function isValidAddress(address) {
    return /^(0x)?[0-9a-f]{40}$/i.test(address);
}

// Basic validation of amount. Bigger than 0 and typeof number
function isValidAmount(amount) {
    return amount > 0 && typeof Number(amount) == 'number';    
}	

Coin.prototype.bindButtons = function() {
    var that = this;

    $(document).on("click", "#createUser", function() {
        that.newUser();
    });

    
}

	



if(typeof(Contracts) === "undefined") var Contracts={ TaskCreate: { abi: [] }};
var taskCreate = new TaskCreate(Contracts['TaskCreate']);

$(document).ready(function() {
    taskCreate.onReady();
});
