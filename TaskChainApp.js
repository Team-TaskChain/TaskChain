<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Raleway">
    <script type="text/javascript" src="https://unpkg.com/jquery@3.3.1/dist/jquery.js"></script>
    <script type="text/javascript" src="https://unpkg.com/web3@0.20.5/dist/web3.min.js"></script>
    <!-- The generated javascript and app.js will be substituted in below -->
    <!-- JAVASCRIPT -->

    <!-- The app.css contents will be substituted in below -->
    <!-- STYLE -->

    <style>
        body,
        h1,
        h2,
        h3,
        h4,
        h5 {
            font-family: "Raleway", sans-serif
        }
    </style>

<body class="w3-light-grey">
    <nav class="w3-sidebar w3-indigo w3-collapse w3-top w3-large w3-padding"
        style="z-index:3;width:300px;font-weight:bold;" id="mySidebar"><br>
        <a href="javascript:void(0)" onclick="w3_close()" class="w3-button w3-hide-large w3-display-topleft"
            style="width:100%;font-size:22px">Close Menu</a>
        <div class="w3-container">
            <h3 class="w3-padding-64"><b>TaskChain<br>Functions</b></h3>
        </div>

        <!-- Top menu on small screens -->
        <header class="w3-container w3-top w3-hide-large w3-red w3-xlarge w3-padding">
            <a href="javascript:void(0)" class="w3-button w3-red w3-margin-right" onclick="w3_open()">☰</a>
            <span>TaskChain Functions Menu</span>
        </header>
        <div class="w3-bar-block">
            <a href="#" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Home</a>
            <a href="#newUserInputTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">New User</a>
            <a href="#upgradeTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Upgrade User</a>
            <a href="#arbitratorTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Create
                Arbitrator</a>
            <a href="#createAdminTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Appoint
                Admin</a>
            <a href="#adminControlTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Admin Access
                Control</a>
            <a href="#createContractTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Create
                Contract</a>
            <a href="#performWorkTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Perform Work</a>
            <a href="#reviewWorkTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Review Work</a>
            <a href="#arbitrateWorkTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Arbitrate
                Work</a>
            <a href="#transferEscrowTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Transfer
                Escrow</a>
            <a href="#cashOutWorkerTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Cash Out
                (Worker)</a>
            <a href="#cashOutArbitratorTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Cash Out
                (Arbitrator)</a>
            <a href="#checkContractBalTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Check
                Contract Balance</a>
            <a href="#closeContractTag" onclick="w3_close()" class="w3-bar-item w3-button w3-hover-white">Close
                Contract</a>

        </div>
    </nav>
    <div class="w3-main" style="margin-left:340px;margin-right:40px">

        <h1>Welcome to TaskChain </h1><br>
        <div class="message"></div>
        <h2><b>New User and Adminstrative Section</b></h2>
        <hr style="width:50px;border:5px solid red" class="w3-round">

        <div class="w3-content">
            <div></div>
            <h3 id="newUserInputTag">Please Input UserName and Type</h3>
            <label for="userName">userName</label><br>
            <input type="text" id="userName" placeholder="User Name"><br>
            <form>
                <select id="userType">
                    <option value="0">Creator</option>
                    <option value="1">Worker</option>
                </select>
            </form>
            <button class="w3-ripple w3-white w3-hover-indigo" id="createUser">Create User</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="getUserCountTag">isUser</h3>
            <label for="userCheckAddress">Address</label>
            <input type="text" id="userCheckAddress" plaeholder="address"><br>
            <button class="btn" id="getUserCountBtn">isUser</button>
            <h4 class="text message">Balance:&nbsp;<span id="message"></span></h4>

        </div><br><br>

        <div class="w3-content">
            <h3 id="upgradeTag">Upgrade User to New Tier</h3>
            <button class="btn" id="updateUserTier">Upgrade User</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="arbitratorTag">Create Arbitrator</h3>
            <button class="btn" id="appointArbitrator">Request Arbitrator Status</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="createAdminTag">Appoint Admin</h3>
            <label for="adminAddress">Admin Address:</label>
            <input type="text" id="adminAddress" placeholder="address"><br>
            <button class="btn" id="createAdmin">Upgrade to Admin</button>
            <button class="btn" id="demoteAdmin">Demote Admin</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="adminControlTag">Admin Access Control</h3>
            <label for="restrictAccountAddress">Address to be Changed:</label>
            <input type="text" id="restrictAccountAddress" placeholder="address"><br>
            <button class="btn" id="restrictAccount">Restrict Account</button>
            <button class="btn" id="restoreAccount">Restore Account</button>
        </div><br><br>
        <h2><b>TaskCreate Section</b></h2>
        <hr style="width:50px;border:5px solid red" class="w3-round">

        <div class="w3-content">
            <h3 id="createContractTag">Create New Contract</h3>
            <label for="msgValue">Task Total Value:</label><br>
            <input type="number" id="msgValue" placeholder="value"><br>
            <label for="quota">Number of Workers Desired:</label><br>
            <input type="number" id="quota" placeholder="quota">
            <form id="taskTier">
                <select>
                    <option value=0>Tier One</option>
                    <option value=1>Tier Two</option>
                    <option value=2>Tier Three</option>
                </select>
            </form>

            <button class="btn" id="createContract">Create Contract</button>
        </div>
        <div class="w3-content">
            <br><br>
            <h3 id="performWorkTag">Perform Work</h3>
            <label for="completeWorkAddress">Task Address:</label><br>
            <input type="text" id="completeWorkAddress" placeholder="address"><br>
            <button class="btn" id="completeWork">Complete Work</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="reviewWorkTag">Review Work(Creator)</h3>
            <label for="reviewAddress">Address to Review</label><br>
            <input type="text" id="reviewAddress" placeholder="address"><br>
            <form>
                <select id="reviewPassFail">
                    <option value=true>Pass</option>
                    <option value=false>Fail</option>
                </select>
            </form><br>
            <button class="btn" id="reviewWork">Complete Review</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="arbitrateWorkTag">Arbitrate Work</h3>
            <label for="contractArbAdd">Contract Address:</label>
            <input type="text" id="contractArbAdd" placeholder="address"><br>
            <label for="workerArbAdd">Worker Address:</label>
            <input type="text" id="workerArbAdd" placeholder="address"><br>
            <form id="reviewArbPassFail">
                <select>
                    <option value=0>Pass</option>
                    <option value=1>Fail</option>
                </select>
            </form><br>
            <button class="btn" id="arbitrateWork">Complete Arbitration</button>
        </div><br><br>
        <div class="w3-content">
            <h3 id="transferEscrowTag">Transfer from Escrow(Workers)</h3>
            <button class="btn" id="transferEscrow">Transfer to Account</button>
        </div><br><br>

        <div class="w3-content">
            <h3 id="cashOutWorkerTag">Cash Out (Worker)</h3>
            <button class="btn" id="workCashOut">Cash out Balance</button>
        </div><br><br>

        <div class="w3-content">
            <h3 id="cashOutArbitratorTag">Cash Out (Arbitrator)</h3>
            <button class="btn" id="arbitratorCashOut">Cash out Balance</button>
        </div><br><br>

        <div class="w3-content">
            <h3 id="checkContractBalTag">Check Contract Balance(Creator)</h3>
            <button class="btn" id="checkContractBal">Contract Bal</button>
            <h3 class="text message">Balance:nbsp;<span id="contractBalanceMessage"></span></h3>
        </div><br><br>

        <div class="w3-content">
            <h3 id="closeContractTag">Close Contract(Creator)</h3>
            <button class="btn" id="closeContractButton">Close Contract</button>
            
        </div><br><br>




        </head>

        <body>
            <h1><span id="message"></span></h1>
        </body>

</html>
