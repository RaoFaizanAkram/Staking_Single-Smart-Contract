// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MegaStake is ERC20, AccessControl, ERC20Capped {
    using SafeMath for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address _owner;
    uint256 public _timeInterval = 20 seconds;
    uint256 _claimedRewards;


    uint256 public _totalSupply;
    uint256 public _InitialSupply;

    uint256 public _start;
    uint256 public _Interval;
    uint256 public _TimeInterval;
    uint256 public primevalue;
  
   
    
    mapping(address => uint256) public _Reward;
    mapping(address => uint256) public _StakeBalance;
    mapping(address => uint256) public _StakeTime;
    mapping(address => bool) public _StakeHolder;

    constructor() ERC20("MegaStake", "MST") ERC20Capped(2100000000 * (10**18)) {
        _InitialSupply = 1200000 * (10**uint256(18));
        _owner = 0x98fcf6bCD19A921Ec917e2227FCD8b4173327Bcd;
        _setupRole(MINTER_ROLE, 0x98fcf6bCD19A921Ec917e2227FCD8b4173327Bcd);
        _mint(_owner, _InitialSupply);
    }




    function stake(uint256 StakeAmount) public {
        require(balanceOf(msg.sender) >= StakeAmount, "Amount is Exceeded");

        if (_StakeHolder[msg.sender] == true) {
            _StakeTime[msg.sender] = block.timestamp - _StakeTime[msg.sender];
            _Reward[msg.sender] +=
                (_StakeTime[msg.sender] * _StakeBalance[msg.sender] * 3) /
                100 /
                _timeInterval;
            _StakeTime[msg.sender] = block.timestamp; //UPDATE the current Time.
            _StakeBalance[msg.sender] += StakeAmount; //UPDATE the current Amount.
        } 
        else
        {
            _StakeHolder[msg.sender] = true; //Here we keep track of whho is stakeholder or not that can be checked through mapping
            _StakeBalance[msg.sender] += StakeAmount; // Here we keep track of stakeholder amount that can be cehcked through mapping
            _StakeTime[msg.sender] = block.timestamp ; // Old time
            _start =  block.timestamp;
    
        }
    }

        function CalculateReward(address account) public view returns(uint256) {     
        
        require(_StakeHolder[account] == true);
        uint256 NowReward = ((block.timestamp -_start) * _StakeBalance[account] * 3) /
                    100 /
                    _timeInterval;
        return NowReward;
        
        }


    function ClaimReward() public {
        require(block.timestamp >= _StakeTime[msg.sender] + _Interval);
        _Interval = (block.timestamp - _StakeTime[msg.sender])/_timeInterval;
        if(_Interval < 1){
        revert(" Time is not yet completed");
        }
        else {
        _Reward[msg.sender] = (_Interval * _StakeBalance[msg.sender] * 3/100);
        }
    }


    function unstake() public {
        _transfer(_owner,msg.sender,_Reward[msg.sender]);
      _StakeBalance[msg.sender] -= _StakeBalance[msg.sender];


    }


    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _mint(to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Capped)
    {
        require(
            totalSupply() + amount <= 2100000000 * 10**decimals(),
            "Max number of tokens minted"
        );
        super._mint(to, amount);
    }
}
