pragma solidity ^0.8.0;

contract EnviroTrack {
    mapping(address => uint256) public tokenBalance;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public environmentalOffsets;

    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public tokenPrice;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensSold(address indexed seller, uint256 amount);
    event EnvironmentalOffsetsClaimed(address indexed account, uint256 amount);

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 decimalUnits,
        uint256 initialSupply,
        uint256 pricePerToken
    ) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        totalSupply = initialSupply * 10**uint256(decimalUnits);
        tokenPrice = pricePerToken;
        tokenBalance[msg.sender] = totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return tokenBalance[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "Invalid recipient address");
        require(value > 0, "Invalid token amount");
        require(tokenBalance[msg.sender] >= value, "Insufficient balance");

        tokenBalance[msg.sender] -= value;
        tokenBalance[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "Invalid spender address");

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        require(from != address(0), "Invalid sender address");
        require(to != address(0), "Invalid recipient address");
        require(value > 0, "Invalid token amount");
        require(tokenBalance[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");

        tokenBalance[from] -= value;
        tokenBalance[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function buyTokens(uint256 numberOfTokens) external payable {
        require(msg.value == numberOfTokens * tokenPrice, "Incorrect amount of Ether sent");
        require(numberOfTokens > 0, "Invalid token amount");

        uint256 tokensToTransfer = numberOfTokens * 10**uint256(decimals);
        require(tokenBalance[address(this)] >= tokensToTransfer, "Insufficient token balance");

        tokenBalance[address(this)] -= tokensToTransfer;
        tokenBalance[msg.sender] += tokensToTransfer;

        emit TokensPurchased(msg.sender, tokensToTransfer);
    }

    function sellTokens(uint256 numberOfTokens) external {
        require(numberOfTokens > 0, "Invalid token amount");
        require(tokenBalance[msg.sender] >= numberOfTokens, "Insufficient balance");

        uint256 tokensToTransfer = numberOfTokens * 10**uint256(decimals);

        tokenBalance[msg.sender] -= tokensToTransfer;
        tokenBalance[address(this)] += tokensToTransfer;

        payable(msg.sender).transfer(numberOfTokens * tokenPrice);

        emit TokensSold(msg.sender, tokensToTransfer);
    }

    function claimEnvironmentalOffsets(uint256 amount) external {
        require(amount > 0, "Invalid environmental offset amount");
        require(tokenBalance[msg.sender] >= amount, "Insufficient balance");

        tokenBalance[msg.sender] -= amount;
        environmentalOffsets[msg.sender] += amount;

        emit EnvironmentalOffsetsClaimed(msg.sender, amount);
    }
}
