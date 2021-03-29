// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.3;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function getBalance(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferTokens(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getapproval(address tokenOwner, address other)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20Token is IERC20 {
    string public constant name = "Mandraki";
    string public constant symbol = "MDK";
    uint8 public constant decimals = 18;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    uint256 _totalSupply = 1000 ether;
    using SafeMath for uint256;

    constructor() {
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // gets the balance of given account
    function getBalance(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    function getapproval(address tokenOwner, address other)
        public
        view
        override
        returns (uint256)
    {
        return allowed[tokenOwner][other];
    }

    //transfer tokens from owner address
    function transferTokens(address receiver, uint256 numTokens)
        public
        override
        returns (bool)
    {
        require(numTokens <= balances[msg.sender], "Not Enough Tokens!");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // allows 3rd party to complete a transaction on your behalf
    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // returns amount of tokens the 3rd party is allowed to send from owners address
    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    // allows a 3rd party to send funds from an address to another if they have approval to
    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        // require(numTokens <= balances[owner], "Not Enough Tokens!");
        // require(numTokens <= allowed[owner][address(this)], "Approved limit hit!");
        balances[owner] = balances[owner].sub(numTokens);
        // allowed[owner][address(this)] = allowed[owner][address(this)].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        Transfer(owner, buyer, numTokens);
        return true;
    }
}

// adding to break if assert does not come back true;
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract DEX {
    IERC20 public token;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor() {
        token = new ERC20Token();
    }

    function returnAddress() public view returns (uint256) {
        return address(this).balance;
    }

    function buy() public payable returns (address) {
        uint256 amountToBuy = msg.value;
        uint256 dexBalance = token.getBalance(address(this));
        require(amountToBuy > 0, "You need to send funds");
        require(amountToBuy <= dexBalance, "Not enough liquidity");
        token.transferTokens(msg.sender, amountToBuy);
        emit Bought(amountToBuy);
        return address(this);
    }

    function allow() public returns (bool) {
        token.approve(msg.sender, token.getBalance(msg.sender));
        return true;
    }

    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell larger than 0");
        // allows dex to transfer "amount" of tokens
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }

    function getTotal() public view returns (uint256) {
        return token.getBalance(msg.sender);
    }

    function getDelegate() public view returns (address) {
        return msg.sender;
    }
}
