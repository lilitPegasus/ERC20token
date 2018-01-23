pragma solidity ^0.4.15;//Версия Solidity

//Используем шаблон для токена ZeppelinSolidity из репозитория https://github.com/OpenZeppelin/zeppelin-solidity

// Интерфейс для ERC179 стандрата
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// Интерфейс для ERC20 стандрата
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
*Библиотека для безопасных математических функций который генерируют ошибку
*в случае деления на ноль или некорректно введенных данных
*/
library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
* Реализация ERC179 интерфейса
*/
contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
   * @dev transfer token for a specified address
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

// Реализация ERC20 интерфейса

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}

/* Контракт для инициализации базовой информации по токену*/
contract SimpleTokenCoin is MintableToken {

    string public constant name = "Simple ERC20 Token";

    string public constant symbol = "SET";

    uint32 public constant decimals = 18;

}

/*Контракт для краудсейла*/
contract Crowdsale is Ownable {

    using SafeMath for uint;

    // Адрес, на который перечислиться весь эфир с покупки токенов
    address public multisig;

    // Процент от общего количества токенов который получит команда
    uint public restrictedPercent;

    //Адрес для командных токенов
    address public restricted;

    SimpleTokenCoin public token = new SimpleTokenCoin();

    //Время начала распродажи
    uint public start;

    //Длительность распродажи
    uint public period;

    //Граница суммы сбора средств
    uint public hardcap;

    //Коэффициент пересчета эфира в наши токены
    uint public rate;

    //Граница возврата средств
    uint public softcap;

    //Маппинг для возврата средств
    mapping(address => uint) public balances;

    //Инициализируем данные
    function Crowdsale() {
      multisig = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
      restricted = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
      restrictedPercent = 30;
      rate = 100000000000000000000;
      start = 1500379200;
      period = 28;
      hardcap = 10000000000000000000000;
      softcap = 1000000000000000000000;
    }

    //Модификатор проверки на истечение срока Crowdsale
    modifier saleIsOn() {
      require(now > start && now < start + period * 1 days);
      _;
    }
	  //Модификатор проверки на достижение цели ICO
    modifier isUnderHardCap() {
      require(multisig.balance <= hardcap);
      _;
    }
    //Функция для возврата средств
    function refund() {
      //Доступна только по истечение срока Crowdsale и если не достигнут softcap
      require(this.balance < softcap && now > start + period * 1 days);
      uint value = balances[msg.sender];
      balances[msg.sender] = 0;
      msg.sender.transfer(value);
    }
    //Завершение выпуска токенов
    function finishMinting() public onlyOwner {
      if(this.balance > softcap) {
        multisig.transfer(this.balance);
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
        token.mint(restricted, restrictedTokens);
        token.finishMinting();
      }
    }

   //Функция для покупки токенов
   function createTokens() isUnderHardCap saleIsOn payable {
      uint tokens = rate.mul(msg.value).div(1 ether);

      /*Распределение бонусных токенов указанное в четвертях
      *первая четверть +25%
      *вторая четверть +10%
      *третья четверть +5%
      *четвертая без бонусов
      */
      uint bonusTokens = 0;
      if(now < start + (period * 1 days).div(4)) {
        bonusTokens = tokens.div(4);
      } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
        bonusTokens = tokens.div(10);
      } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
        bonusTokens = tokens.div(20);
      }
      tokens += bonusTokens;
      //Реферальная система
      if(msg.data.length == 20) {
        address referer = bytesToAddres(bytes(msg.data));
        // проверка, чтобы инвестор не начислил бонусы сам себе
        require(referer != msg.sender);
        uint refererTokens = tokens.mul(2).div(100);
        // начисляем рефереру 2% от токенов
        token.transfer(referer, refererTokens);
      }
      token.mint(msg.sender, tokens);
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    //Превращает данные переданные с msg.data в адрес, если был указан реферер
    function bytesToAddress(bytes source) internal pure returns(address) {
      uint result;
      uint mul = 1;
      for(uint i = 20; i > 0; i--) {
        result += uint8(source[i-1])*mul;
        mul = mul*256;
      }
      return address(result);
    }

    //Вызывается при перечислении эфира на счет контракта
    function() external payable {
      createTokens();
    }

}
