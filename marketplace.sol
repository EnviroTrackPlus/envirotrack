// Environmental Credits Marketplace Contract
contract EnvironmentalCreditsMarketplace {
    EnvironmentalCreditToken public tokenContract;
    uint256 public tokenPrice;
    mapping(address => uint256) public tokenBalance;
    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensSold(address indexed seller, uint256 amount);
    constructor(address tokenAddress, uint256 pricePerToken) {
        tokenContract = EnvironmentalCreditToken(tokenAddress);
        tokenPrice = pricePerToken;
    }
    function buyTokens(uint256 numberOfTokens) external payable {
        require(msg.value == numberOfTokens * tokenPrice, "Incorrect amount of Ether sent");
        require(numberOfTokens > 0, "Invalid token amount");
        uint256 tokensToTransfer = numberOfTokens * 10**uint256(tokenContract.decimals());
        require(tokenContract.balanceOf(address(this)) >= tokensToTransfer, "Insufficient token balance");
        tokenContract.transfer(msg.sender, tokensToTransfer);
        tokenBalance[msg.sender] += tokensToTransfer;
        emit TokensPurchased(msg.sender, tokensToTransfer);
    }
    function sellTokens(uint256 numberOfTokens) external {
        require(numberOfTokens > 0, "Invalid token amount");
        uint256 tokensToTransfer = numberOfTokens * 10**uint256(tokenContract.decimals());
        require(tokenBalance[msg.sender] >= tokensToTransfer, "Insufficient token balance");
        tokenContract.transferFrom(msg.sender, address(this), tokensToTransfer);
        tokenBalance[msg.sender] -= tokensToTransfer;
        payable(msg.sender).transfer(numberOfTokens * tokenPrice);
        emit TokensSold(msg.sender, tokensToTransfer);
    }
}