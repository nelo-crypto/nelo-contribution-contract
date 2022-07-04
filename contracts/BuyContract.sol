// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Common/IUniswapV2Router.sol";
import "./Common/IERC20.sol";
import "./Common/Referral.sol";

contract BuyContract is Ownable, Referral {
    address public _trueOwner;
    address public _usdcToken;
    address public _neloToken;
    address public _router;
    uint256 public _price = 10 * 1e18;
    bool public _active = true;

    uint256[] _levelRate = [6000, 3000, 1000];
    uint256[] _refereeBonusRateMap = [1, 10000];

    event Buy(
        address indexed buyer,
        uint256 amount
    );

    constructor() Referral (10000, 1000, 3650 days, false, _levelRate, _refereeBonusRateMap)
    {
        _usdcToken = address(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
        _neloToken = address(0xA9a2565C7e055eEe01E944cf4D6836074100Fdf3);
        _trueOwner = address(0x26b9fD8EF7a6d2f0612D4953CE7A06Fe8d90dd66);
        _router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        _transferOwnership(_trueOwner);
    }

    modifier onlyActive() {
        require(_active == true, "02: Contract must be active");
        _;
    }

    function setPrice(uint256 price) public onlyOwner {
        _price = price;
    }

    function setActive() public onlyOwner {
        _active = true;
    }

    function setInactive() public onlyOwner {
        _active = false;
    }

    function runRouterApproval(address token) internal {
        uint256 allowance = IERC20(token).allowance(address(this), _router);
        uint256 maxAllowance = 2 ** 256 - 1;

        if (allowance == 0) {
            IERC20(token).approve(_router, maxAllowance);
        }
    }

    function runRouterApprovals() public onlyOwner {
        runRouterApproval(_neloToken);
        runRouterApproval(_usdcToken);
    }

    function buy(address payable referrer) public onlyActive {
        IUniswapV2Router routerInstance = IUniswapV2Router(_router);

        IERC20(_usdcToken).transferFrom(msg.sender, address(this), _price);

        if (!hasReferrer(msg.sender)) {
            addReferrer(referrer);
        }
        payReferral(_price);

        uint256 usdcAmount = IERC20(_usdcToken).balanceOf(address(this));
        uint256 amountTokenIn = usdcAmount / 2;

        address[] memory swapPath = new address[](2);
        swapPath[0] = _usdcToken;
        swapPath[1] = _neloToken;

        routerInstance.swapExactTokensForTokens(
            amountTokenIn,
            0,
            swapPath,
            address(this),
            block.timestamp + 1 days
        );

        uint256 halfUsdcAmount = IERC20(_usdcToken).balanceOf(address(this));
        uint256 halfNeloAmount = IERC20(_neloToken).balanceOf(address(this));

        routerInstance.addLiquidity(
            _usdcToken,
            _neloToken,
            halfUsdcAmount,
            halfNeloAmount,
            0,
            0,
            msg.sender,
            block.timestamp + 1 days
        );

        emit Buy(msg.sender, _price);
    }
}