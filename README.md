solidity 进阶学习笔记

1. netspec注释的两种写法? 
   - 第一种写法 “///@title”
   - 第二种写法 
   “
   /**
    * @title  xxxx
    */
   ”
   - 两种写法都会将注释信息写进 “合约名_metadata.json”文件中

2. pragma solidity ^0.8.17 的作用？如果使用import导入的sol文件使用其他版本，该如何选择合适的版本进行编译 ？
   — 限制solidity语言编译版本
   - 如果import导入的sol文件使用了其他版本,只能使用两者都适用的版本进行编译,否则编译报错


3. constructor里不可以执行哪些操作？
   - constructor构造函数中不能使用this.functionName()调用当前合约的public/external函数，因为合约还未创建成功
   Warning: "this" used in constructor. Note that external functions of a contract cannot be called while it is being constructed.

4. type函数有哪些属性，creationCode 跟 runtimeCode 的区别？
   - type(C).name:获得合约名
   - type(C).creationCode:获得包含创建合约字节码的内存字节数组
   - type(C).runtimeCode:获得合约的运行时字节码的内存字节数组

   - creationCode 跟 runtimeCode 两者的区别参照https://learnblockchain.cn/question/3052

5. 对import导致全局污染的理解？请举出示例
--------NetSpace.sol------------
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
///@title 一个关于注释的小Demo
// import "./Version.sol" as version;
contract Demo {
    uint256 num;
    uint256 num1;

    /// @notice 将_num存储到状态变量num
    function set(uint256 _num) public{
        num = _num;
    }
    
    /**
     * @notice 获取状态变量并将值返回aaaa
     */
    function get() public view returns(uint256){
        return num;
    }

    function test() public pure returns(uint256){
        return 2**3**2;
    }
        
}

contract Demo1 {
    uint256 num;
    uint256 num1;

    /// @notice 将_num存储到状态变量num
    function set(uint256 _num) public{
        num = _num;
    }
    
    /**
     * @notice 获取状态变量并将值返回aaaa
     */
    function get() public view returns(uint256){
        return num;
    }

    function test() public pure returns(uint256){
        return 2**3**2;
    }
        
}

-------Version.sol-----------------
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
// import {Demo as TT} from "./NetSpace.sol";
import {Demo,Demo1}  from "./NetSpace.sol";
contract Test{
    
    uint256 num;
    constructor(){
       num = test();
    }

    function test() public pure returns(uint256){
        return 2**3**2;
    }

    function getName() public pure returns(string memory){
        return type(Demo).name;
    }

    function callDemoTest() public  returns(uint256){
        Demo demo = new Demo();
        return demo.test();
    }

    function callDemo1Test() public  returns(uint256){
        Demo1 demo = new Demo1();
        return demo.test();
    }
}


6.怎么使用自定义接口调用链上合约？ 理解type(I).interfaceId。
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Cat{
    function eat() public pure returns(string memory){
        return "Cat eat fish!!";
    }
}

contract Dog{
    function eat() public pure returns(string memory){
        return "Dog eat bond!!";
    }
}

interface Ainmal {
    function eat() external  pure returns(string memory);
}

contract Demo{
    function eat(address addr) public pure returns(string memory){
        Ainmal ainmal = Ainmal(addr);
        return ainmal.eat();
    }
}
理解流程：
1.部署Cat Dog合约。此两个合约相当于链上合约，取到它们各自的合约地址
2.在本地新建Ainmal接口以及Demo合约
3.在Demo合约中分别传入Cat Dog的合约地址进行调用

-理解type(I).interfaceId 参考https://github.com/ethereum/ercs/blob/master/ERCS/erc-165.md   

-------------------------------------------------
-------------------------------------------------

7.以太坊单位使用？
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo{
    uint256 amount = 1;

    function add() public view  returns(uint256){
       return amount + 1 wei;
    }

    function add(uint256 num) public view  returns(uint256){
    //    return amount + num ether;// 错误示例
       return amount + num * 1 ether;
    }

    function verify() public pure  returns(bool,bool,bool){
        bool onewei = 1 wei == 1;
        bool onegwei = 1 gwei == 10 ** 9;
        bool oneether = 1 ether == 10 ** 18;

        return (onewei,onegwei,oneether);
    }
     
}

8. payable \ fallback \ receive 概念理解 以及 fallback跟receive的区别？

   - payable 用在方法上标明此方法可以接受ether：
    function deposit() public payable {}
   - payable 用在地址上 payable(address) 标明此地址可以接受ether

   - fallbak函数格式
      - 无参 fallback() external [payable] {}
      - 有参 fallback(bytes calldata input) external [payable] returns(bytes memory output){}
          - 参数input 跟 msg.data 内容是一样，前四个字节是函数选择器，之后是对应的32字节的参数。
          - 可以通过uint256 param = abi.decode(msg.data[4:],(uint256)) 获取参数内容
   - receive函数格式
      receive() external payable{}
   
   - fallback 跟 receive 的区别 
      - fallback 可以接受ether,同时它还类似兜底方法，当使用底层调用未找到相应的方法也会执行fallback函数
      - receive  仅限接受ether
      - 如果msg.data为空, 并存在receive方法，将执行receive ，否则执行fallback

    - address.transfer(amount) 、 address.send(amount) 以及 address.call.value(amount)() 区别
       参考https://blog.csdn.net/weixin_39915815/article/details/111140795
       - fallback 、receive 函数接收address.transfer(amount) 、 address.send(amount)转账会有2300gas的限制
       - fallback 、receive 函数接收address.call.value(amount)()不会有2300gas的限制

9. 执行selfdestruct销毁之后还能转钱进合约吗？
    -selfdestruct（address） 功能：
       1.销毁合约
       2.将合约余额发送到指定定制
    - 执行selfdestruct销毁之后还能继续转钱进合约

    

10. 需要使用中文的地方 需使用 unicode“中文” 进行转码

11.字符串怎么判断是否相等?
    - keccak256(abi.encodePack(str1)) == keccak256(abi.encodePack(str2))

12. 理解变量、Constant（常量） 、 immutable （不可变量）之间的区别
    Constant（常量）是在内存在，immutable(不可变量)长久存储在运行时字节码中并不会预留存储槽。
    参考Anbang youtube视频47、48章节

13. .sol文件中只有常量可以定义在合约外，同时定义在合约外的常量不需要可见性（public、private等等）

14. remix 中gas \ execution cost \transaction cost的区别
   gas：也就是gas limit，需要注意的是remix的测试网络中limit是自动设置的，手动填无效。我猜是为了避免新手不懂合理设置导致交易失败的情况发生。

   transaction cost：整笔交易消耗的gas总量，只有比limit小才能让这笔交易成功上链。

   execution cost：执行智能合约代码消耗的gas总量，它是 transaction cost的一部分。

   gas相关概念参考https://www.bitget.fit/zh-CN/news/detail/12560603813967
   
15. memory 跟 calldata可以互转吗？
   - calldata 可以隐式转换为 memory
   - memory 不可以隐式转换为 calldata
   参考Anbang youtube视频31章节


16..sol文件如果编译出错,可以部署吗？ 如果可以，部署后的效果是怎么样的？

17.值类型跟引用类型的区别？
   值类型始终传递值本身，也就是创建一个新副本，
   引用类型可以传递值 也可以传递引用，跟当前变量的位置(memory\storage)有关系
        - memory -> memory  传递引用
        - 状态变量storage -> 局部storage变量 传递引用
        - 其他情况都是传递值
18.type(uint8).max \ type(uint128).max的最大值分别多少，它的规律是什么？
   type(uint8).max = 2 ** 8 - 1 
   type(uint128).max = 2 ** 128 -1 
   规律是2 ** N - 1;
   都需要减1，是因为数字0需要占一个位置。

19.分别计算type(int8).max \ type(int8).min的值，得到它们的规律？
   type(int8).max = (2 ** 8/2) - 1  = 127
   type(int8).min = -2 ** 8/2 = -128
   type(int8).max的规律是 (2**N/2)-1 
   type(int8).min的规律是-2**N/2
   其中N代表int类型的位数，比如int16中N = 16 ;

20.为什么uint8/int8 到 uint256/int256 都是以8的倍数递增 且最大值是256？
   - 字节(Byte)是电脑中表示信息含义的最小单位，因为在通常情况下一个ACSII码就是一个字节的空间来存放。
     而事实上电脑中还有比字节更小的单位，因为一个字节是由八个二进制位（即0 或 1）组成的，换一句话说，
     每个二进制位所占的空间才是电脑中最小的单位，我们把它称为位，也称比特（bit）。
     由此可见，一个字节等于八个位(1 byte = 8 bit ). 所以uint8/int8 到 uint256/int256 都是以8的倍数递增。
   - 因为 evm 设置的存储最大长度是256位, 所以uint/int 最大值uint256/int256.


21.为什么int8的取值范围是-128 - 127 ？
   - 原码跟反码、补码中最高位表示符号,0为正,1为负
   - 计算机中均采用补码进行运算
   - 反码是为了解决减法运算，补码是为了解决反码产生的+-0的问题
   - 正数的原码反码补码是一样的 对于负数来说，它的原码反码补码就不相同
   - 负数计算反码的规则是符号位不变，其余位取反即1变成0,0变成1，补码就是反码再加1
   - 从补码求原码的方法跟原码求补码是一样的
   - 0原码为0000 0000，-0原码为1000 0000，在反码中+0跟-0也同时存在，去除符号位都为0，
     在补码中-0是不存在的，补码中+0用[0000 0000]表示，同时规定1000 0000（即-0的原码）在补码中表示 -128
   - (-128)并没有原码和反码表示. 根据-128的补码[1000 0000]计算出来的原码是[0000 0000], 这是不正确的
   - 使用原码或者反码表示的范围是[-127~127] 即[1111 1111 - 0111 1111],其中同时包含了+0[0000 0000]跟-0[1000 0000]
      而 (-126)的补码为[1000 0010](-127)的补码为[1000 0001]同时规定(-128)的补码为[1000 0000]
      所以使用补码表示的范围为[-128~127]即[1000 0000 - 0111 1111]，其中只包含了+0[0000 0000].
22. 计算机中均采用补码进行运算
    - 补码的符号位参与运算
    - 一个补码可能代表一个正数、也可能代表一个负数，取决于变量的类型 
    - 但是仅限于首位为1开头的补码，比如 1000 1100、1111 0000等，
    - 首位为0开头的补码只能代表正数。 如：
    function test() public pure returns(int8){
        uint8 a = 129;//1000 0001 
        return int8(a); // 返回-127
    }

    function test() public pure returns(uint8){
        int8 a = -127;//1000 0001 
        return uint8(a); // 返回129
    }

    首位为1开头的补码所代表的正数跟负数的真值计算规则为：
    如：补码 1000 1100
    负数：1 * 2 **2 + 1 * 2 ** 3 - 1 * 2 ** 7 = 4 + 8 - 128 = -116
    正数：1 * 2 **2 + 1 * 2 ** 3 + 1 * 2 ** 7 = 4 + 8 +128 = 140
    

23.字节(byte) & 位(bit) & 16进制数字的关系？
    - 1 byte = 8 bit = 0xff 即16进制的一位代表4bit

24.checked / unchecked 的由来以及具体使用
    - solidity在0.8版本之前需要用户自行检测溢出比如使用SafeMath
    - 之后版本会自动检测溢出即默认就是checked模式
    - 如果使用unchecked模式 需要用户自行检测溢出
      如果溢出，得到结果是截断的结果。而不是抛出异常错误.
      字节类型由大变小，右边将舍弃 ，整数类型由大变小，左边将舍弃


25. 熟悉位运算。
    - 位操作是在数字的二进制补码上进行的
    - 左位移 右边用0填充
    - 右位移 正数左边用0填充 负数左边用1填充   
    - 在 0.5.0 版本之前，负数 x 的右移 x >> y 相当于数学表达式 x / 2**y 向零舍入， 
      即右移使用向上舍入（向零舍入）而不是向下舍入（向负无穷大）, 如：
      -3 >> 3  在0.5之前得出的结果是0,0.5之后得出的结果是-1。

26.整数字面常量需要注意的地方
    - 为增加可读性可使用如下格式:
      uint256 num = 123_456_789
    - 正数字面常量支持任意精度 如下：
      Uint8 num = (2**800 + 1) - 2 ** 800;
      uint8 num1 = 0.5 * 8;
    - 需要注意的地方：
      uint8 a = 1;
      uint8 num2 = 0.5 + 0.5 + a ; √ 正常运行
      uint8 num3 = 0.5 + a + 0.5 ; × 编译出错
      
      uint8 a = 1;
      uint8 b = 4;
      uint8 c1 = (1/4)*4; // 正常运行 返回结果1 因为字面常量会保留精度
      uint8 c2 = (a/b)*b; // 返回结果0

      特殊情况- 以下情况执行会报错：
      type(int256).min/(-1) 



    你可能认为像255 + (true ? 1 : 0) 或 255 + [1, 2, 3][0] 这样的表达式等同于直接使用 256 字面常量。 
    但事实上，它们是在 uint8 类型中计算的，会溢出。
    // VM error: revert.
    function testA1() public pure returns (uint256 a) {
        a = 255 + (true ? 1 : 0);
    }

    // VM error: revert.
    function testA2() public pure returns (uint256 a) {
        a = (true ? 1 : 0) + 255;
    }

    // VM error: revert.
    function testB1() public pure returns (uint256 a) {
        a = 255 + [1, 2, 3][0];
    }
    // VM error: revert.
    function testB2() public pure returns (uint256 a) {
        a = [1, 2, 3][0] + 255;
    }
    // success
    function testA3() public pure returns (uint256 a) {
        a = 255 + uint256(true ? 1 : 0);
    }
    // success
    function testB3() public pure returns (uint256 a) {
        a = 255 + uint256([1, 2, 3][0]);
    }

27 .16进制怎么表示负数？
    - 前面直接加“-”就行，如
    int8 num = -0x0e;

28. 理解定长浮点型
    - solidity 暂时不支持定长浮点型，
    - 可以通过使用外部libaray 如prb-math github地址： https://github.com/PaulRBerg/prb-math/tree/main 来模拟定长浮点型（保留18位精度）的使用
      使用方法如下：
      // SPDX-License-Identifier: MIT
      pragma solidity ^0.8.0;
      import { UD60x18 } from "@prb/math/src/UD60x18.sol";
      import "@prb/math/src/ud60x18/Conversions.sol"; 
      
      contract Demo{
          function div(UD60x18 x, UD60x18 y) public pure returns (UD60x18 result){
              return  x.div(y);   // 输入UD60x18 1000000000000000000  跟 UD60x18 2000000000000000000 得到UD60x18 500000000000000000
          }
          function mul(UD60x18 x, UD60x18 y) public pure returns (UD60x18 result) {
              return x.mul(y);  // 输入UD60x18 18000000000000000000  跟 UD60x18 1000000000000000000  得到UD60x18 18000000000000000000
          }
          function change1(uint256 num)  public pure returns (UD60x18 result){
            return  convert(num);// 输入 uint256 18 得到UD60x18 18000000000000000000 
          }
          function change2(UD60x18 num)  public pure returns (uint256 result){
            return  convert(num); // 输入UD60x18 18000000000000000000 得到 uint256 18
          }
      
      }
      使用只需要将基本类型uint256/或者int256转换成UD60x18或SD59x18 ,
      之后所有的运算都使用prb-math libaray提供的方法,得到的结果都是保留18位精度。

29 .怎么理解 整数字面常量优先使用较小类型？
    contract Demo{
       function test(uint256[3] memory nums) public pure {   
       }
       function callTest() public pure{
           // test([1,2,3]);//根据整数字面量优先使用较小数据类型可以推断出 [1,2,3]是一个uint8[3]的数组，而uint8[3]是无法隐式转换成uint256[3]
           test([uint256(1),uint256(2),uint256(3)]);
       }
       function test1(uint256 num) public pure {   
       }
       function callTest1() public pure{
           test1(1);//这里可以调用成功 ， 是因为uint8可以隐式转换成Uint26
       }
    }

30.定长字节数组的赋值形式有哪些？可以使用数字赋值吗？
    contract Demo{
        // bytesN类型两种赋值形式：字符串字面常量跟十六进制数
        bytes1 public a1 = "a";
        bytes1 public b1 = 0x61;
        // 需要注意的点 如下：
        bytes2 public a2 = "a";// 正确：使用字符串字面常量赋值给bytesN类型，系统会自动转换成跟bytesN类型保持一致的十六进制，a2得到的结果是0x6100.
        bytes2 public b2 = 0x6100;//正确
        // bytes2 public b3 = 0x61;// 错误：使用十六进制的值赋值给bytesN类型，值的位数必须跟bytesN类型保持一致，但是0特殊，不需要匹配

    
        //不能使用数字给bytesN类型赋值，但是bytesN类型可以跟uint类型相互显示转换，前提是bytesN类型跟uint类型 的bit数需要一致。
        // bytes1 public a3 = 97; 错误：
        // uint8 public c = uint8(bytes2("a"));//错误
        uint8 public c = uint8(bytes1("a"));//97
        bytes1 public d = bytes1(uint8(97));
    }
  

31.定长字节数组有哪些属性？
    // length属性
    function length() public view returns(uint8){
        return b2.length;
    }
     // index属性
    function index() public view returns (bytes1 ){
        return b2[0];
    }
     // 不能通过index属性修改bytesN的值
    // function setValue() public view{
    //     b2[0] = 0x62;//TypeError: Single bytes in fixed bytes arrays cannot be modified.
    // }

32.字符串字面常量 赋值给bytesN 跟 string 有什么区别？
    contract Demo{
        bytes1 public b = 0x61;//得到十六进制数 0x61
        string public a = "a";// 得到字符串 “a”
    }

33. bytesN 跟bytes的值在计算机内部都是使用十六进制表示的吗 ？
   - 计算机底层都是通过二进制（0001 1101），但是为了更加直观bytesN 跟bytes的值都是通过十六进制表示的，如下：
    bytes1 public b1 = 0x61;//输出0x61
    bytes2 public a2 = "a";//输出0x6100
    bytes public bts = "abc";//输出0x616263
    --注意bytes的值最终输出的十六进制常量，
    但是要将十六进制常量赋值给bytes类型只能使用hex"616263"这种形式，而不能使用0x616263这种形式
     bytes public bts1 = "abc";
    // bytes public bts2 = 0x616263;//错误
    bytes public bts2 = hex"616263";//正确
    // string public str1 = 0x616263;//错误
    string public str2 = hex"616263";//正确
    bytes2 public bt1 = 0x6162;//正确
    bytes2 public bt2 = hex"6162";//正确

34. 十六进制字面常量 有几种书写形式 ？
    // 十六进制字面常量两种表现形式0x61 跟 hex"61"
    bytes1 public a1 = hex"61";
    bytes1 public b1 = 0x61;
    //同时为了书写美观，十六进制字面常量（字符串常量也支持）支持一下形式：
    bytes3 public a2 = hex"61" hex"61" hex"61";
    string public c = "a" "b" "c";
    //整数字面常量为了书写美观 支持一下格式：
    uint256 public num = 123_456_789;

35. enum包含哪些方法？
   - type(enum).max \type(enum).min

36. 理解用户自定义类型
   - 格式 ： type UserType is DefaultType
   - DefaultType 只能是基本的值类型
   - UserType 只有两个方法：
       - UserType.wrap(DefaultType) 将DefaultType转换成UserType
       - UserType.unwrap(UserType)  将UserType转换成DefaultType
    - UserType没有其他任何操作符，如需使用UserType进行运算，需要借助于DefaultType

37 . adress初识
    - address长度为20字节，都是使用40位hex string表示，同时地址需要进行checksum。
        - 1 bytes = 8 bit && 1 hex string = 4bit = > address = 20 bytes = 160 bit => 40 hex string 
    - ens域名值不能赋值给address

38. address bytes20 uint160之间的转换？ 
    bytes32 public bts = 0xabc2939949995930594309543959945cef2939949995930594309543959945Fe;

    // 可以使用address(uint160)、address(bytes20)分别将uint160、bytes20转换成address
    function toAddress1() public view returns(address addr_){
        return address(bytes20(bts)); //0xAbC2939949995930594309543959945CEf293994
    }
    // 转换过程中需要注意：
    // toAddress2()、toAddress3()返回的结果是不一样的
    // 原因是toAddress2()是字节类型由大变小，右边将舍弃 ， 而toAddress3()是整数类型由大变小，左边将舍弃
    function toAddress2() public view returns(address addr_){
        return address(uint160(bytes20(bts))); // 0xAbC2939949995930594309543959945CEf293994
    }
    function toAddress3() public view returns(address addr_){
        return address(uint160(uint256(bts))); // 0x3959945CEF2939949995930594309543959945FE
    }

    // 可以使用bytes20(address)、bytes20(uint160)分别将address、uint160转换成bytes20
    function toBytes201() public view returns(bytes20 ){
        return bytes20(toAddress3()); // 0x3959945cef2939949995930594309543959945fe
    }
    function toBytes202() public view returns(bytes20 ){
        return bytes20(toUint1601()); // 0x3959945cef2939949995930594309543959945fe
    }

    // 可以使用uint160(bytes20)、uint160(address)分别将bytes20、address转换成uint160
    function toUint1601() public view returns(uint160 ){
        return uint160(toAddress3()); // 327410164501823278618170531482029896722615453182
    }
    function toUint1602() public view returns(uint160 ){
        return uint160(toBytes201()); // 327410164501823278618170531482029896722615453182
    }
 
39 . address(0)、address(1)写法正确吗？payable(0) payable(1)写法正确吗？
    - address(0)、address(1)正确,address()函数可以将任意数字转换成address类型。
    - payable(0) 正确； payable(1)错误。payable()函数只能将数字0(其他数字不允许)转换成address payable.



40. msg.sender需要转换成address类型才能调用address类型的属性吗 ？
    -不需要，因为msg.sender本来就是address类型，但是建议转换一下
    function test1() public view returns(uint256){
        return msg.sender.balance;
    }
    function test2() public view returns(uint256){
        return address(msg.sender).balance;
    }
    function test3() public view returns(bytes memory){
        return msg.sender.code;
    }
    function test4() public view returns(bytes memory){
        return address(msg.sender).code;
    }

41. (,bytes memory data ) = address(_addr).call{value:0}("")中data代表什么内容 ？
    - 如果不需要发送ether， 可以写成address(_addr).call(""),不需要加{}
    - data所代表的内容是call所调用函数的返回值，如下：
    contract Demo{
        function test(uint256 num) public pure returns(uint256 ){
            return num+1;
        }
    }
    contract Call{
        function callTest(address _addr) public  returns(uint256){
            bytes memory sign = abi.encodeWithSignature("test(uint256)", 911);
            (,bytes memory data ) = address(_addr).call{value:0}(sign);
            uint256 num = abi.decode(data,(uint256));
            return num; // 912
        }
    }

42. 获取函数选择器的几种方式？
    contract Demo{
        function test(uint256 num) public pure returns(uint256 ){
            return num+1;
        }
    }
    contract Call{
        function selector(address _addr) public pure  returns(bytes4,bytes4,bytes4){
            // 获取函数选择器有三种方式，如下：
            // 第一种通过keccak256函数
            bytes4 bt1 = bytes4(keccak256("test(uint256)"));
            // 第二种通过合约名称
            bytes4 bt3 = Demo.test.selector;
            // 第三种通过合约实例
            Demo demo= Demo(_addr);
            bytes4 bt2 = demo.test.selector;
            return (bt1,bt2,bt3);
        }
    }

43. Demo demo= Demo(_addr) 跟 Demo demo= new Demo()的区别？
    - 使用 new 关键字可以创建新的合约实例，而不使用 new 关键字可以引用现有的合约实例.
    - 具体参考文献https://juejin.cn/post/7229320321340407864
    
44 . abi.encodeWithSelector(bytes4, arg) 跟 abi.encodeWithSignature(signatureString, arg)的使用区别？
    - bytes memory sign = abi.encodeWithSignature("test(uint256)", 911);
      等价于bytes memory sign =  abi.encodeWithSelector(Demo.test.selector, 911);
    contract Demo{
        function test(uint256 num) public pure returns(uint256 ){
            return num+1;
        }
    } 
    contract Call{
        function callTest(address _addr) public  returns(uint256){
            // bytes memory sign = abi.encodeWithSignature("test(uint256)", 911);
            bytes memory sign =  abi.encodeWithSelector(Demo.test.selector, 911);
            (,bytes memory data ) = address(_addr).call(sign);
            uint256 num = abi.decode(data,(uint256));
            return num; // 912
        }
    }
45. 怎么判断一个地址是否为合约地址 ？
    - 可以通过address(_addr).code属性来判断一个地址是否为合约，如果所返回的code长度大于0，说明地址是一个合约地址
    - 但是因为code属性返回的是runtimeCode（即运行性bytescode）,而runtimeCode只有在合约constructor执行完成之后才会生成
    - 所以仅仅通过code属性去判断地址是否是一个合约存在风险，如下代码:
    -(Hacker合约可以领取奖励，但是Gitfs合约的要求是只有外部合约才能领取)
    contract Gitfs{
        mapping (address=>uint256) public balances;
        function gift() public returns(uint256){
            bytes memory code = getCode(msg.sender);
            require(code.length == 0,"invalid contract");
            uint256 bonus = 666;
            balances[msg.sender] = bonus;
            return bonus;
        }  

        function getCode(address _addr) public view returns(bytes memory){
            return address(_addr).code;
        }
    }
    contract Hacker{
        Gitfs gifts;
        constructor(address _addr){
            gifts = Gitfs(_addr);
            gifts.gift();
        }    
    }

46. call、delegatecall、staticcall 的区别？
   -参考文献https://www.cnblogs.com/Soy-technology/p/16450427.html
    (bool success,bytes memory data) = addr.delegatecall(sign);
    成功执行被调用合函数的代码则success 返回true,否则返回false;
    data 是被调用合函数的返回值。如果success返回false,那么data值不具有参考意义（有点乱七八槽）。

47. 使用create2提前获取即将部署的合约地址 可以将工厂合约地址改成外部地址吗？这样预测会准吗？
   - 不行 不行 不行 
   - 需要理解create2的原理 参考文献https://mirror.xyz/xyyme.eth/czipkrvqRwxHUjQey7zeEScfWDEVUYNajMAEo5e7Myw
   - create2只是一个方法，所以必须在合约内调用。如果将工厂合约地址改成外部地址，外部地址没有代码是不能执行create2方法的。
    contract DeployContract{
        uint256 num = 111;
        function getNum() public view returns(uint256){
            return num;
        }
    }
    contract Demo {
        // 获取即将部署的地址
        function getAddress(bytes memory bytecode, uint256 _salt)
            external
            view
            returns (address){
            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff), // 固定字符串
                    address(this), // 当前工厂合约地址 注意这里必须是合约地址，不能是外部地址
                    _salt, // salt
                    keccak256(bytecode) //部署合约的 bytecode
                )
            );
            return address(uint160(uint256(hash)));//0xA90B8E49Fa13E9C4EDF4411F1d5fe7ad04d26de9
        }
        function deploy(bytes memory bytecode, uint256 _salt)
            external
            returns (address){
            address addr;
            require(bytecode.length != 0,"bytecode is zero");
            assembly{
                addr := create2(amount,add(bytecode,0x20),mload(bytecode),_salt)
            }
            return addr;//0xA90B8E49Fa13E9C4EDF4411F1d5fe7ad04d26de9
        }
    }
   
48. 合约类型实例跟address可以互相转换吗？
   - 可以，如下：
    contract Demo{
    }
    contract Test{
        function test1(Demo demo1) public pure returns(address _addr){
            return address(demo1);
        }
        function test2(address _addr) public pure returns(Demo){
            areturn Demo(_addr);
        } 
    }  
    
49. address(_addr).code  跟type(contract Type).creationCode type(contract Type).runtimeCode 区别
   - type(类型)函数中的参数都是类型，而不是类型实例。
   - address(_addr).code可以直接写成_addr.code，但是建议写成address(_addr).code
   - type(contract Type).runtimeCode 跟 address(_addr).code 返回的都是运行字节码。
     它们的区别在于：
        -address.code 表明合约已经部署，已经存在于链上，并且地址为当前的address。
        -type(Contract).runtimeCode 只是通过您导入的合约文件计算出的运行时code，
         可能合约代码还未部署到链上，还没有相应的address.
   - type(contract Type).creationCode 返回的是创建字节码

50.storage、memory、calldata
   - 合约中使用storage存储位置的区域为 合约内函数外
        - 不管是值类型还引用类型变量 都不需要显示指定storage存储位置，因为在此区域内，存储位置只能是storage.
   - 合约中使用memory存储位置的区域为 函数内以及函数参数跟返回值（函数参数跟返回值这个区域跟calldata区域重叠）
        - 函数内
            - 在此区域值类型变量不能显示指定存储位置（默认memory），引用类型变量必须显示指定存储位置（memory、storage）
            - 在此区域引用类型变量显示指定存储位置为storage,则此变量只能通过已存在的状态变量引用赋值,因为此区域为memory 如下：
                string public str = "smile";
                uint256[] public arr = [1,2,3];
                bytes public bts = "smile";
                function test() public view {
                    // string storage innerStr = string("sss"); 错误
                    string storage innerStr = str; //正确
                    // uint256[] storage innerArr = new uint256[](3);错误
                    uint256[] storage innerArr = arr;//正确
                    // bytes storage innerBts = bytes("laughing");错误
                    bytes storage innerBts = bts;//正确
                }              
            - 其他类型此区域的特殊性如下：
                - mapping在所有位置（函数内、参数）只能使用storage存储位置
                  包括任何包含mapping类型的类型比如包含mapping类型的struct 或者 mapping(address=uint256)[] arr.
                - 动态数组使用memory存储位置，不管是函数内还是作为参数或者返回值，都不能动态创建，
                  即不能使用uint256[] memory arr1 = [1,2,3];而只能arr1 = new Uint26[](5);来创建赋值，同时不能使用push函数。         
        - 函数参数跟返回值
            - 在此区域值类型变量不能显示指定存储位置（默认memory），引用类型变量必须显示指定存储位置（memory、calldata 、storage）         
                - 在此区域引用类型变量显示指定存储位置为memory或者calldata,它们的区别如下
                    -calldata类型不能修改、且比memory更省gas
                    -动态数组使用memory存储位置，不管是函数内还是作为参数或者返回值，都不能动态创建，
                     即不能使用uint256[] memory arr1 = [1,2,3];而只能arr1 = new Uint26[](5);使用来创建赋值，同时不能使用push函数。
                     注意：动态字节数组（bytes）虽然可以动态创建，即使用bytes memory bts= "abc"，但是也不能使用push pop函数。
                    -solidity 0.7版本之后才可以使用memory\calldata标识所有可见性的函数，之前跟函数可见性存在关联
                - 在此区域引用类型变量显示指定存储位置为storage,
                    - 不能返回storage存储位置的变量（即返回值不能是storage）
                    - mapping在所有位置（函数内、参数）只能使用storage存储位置 
                      包括任何包含mapping类型的类型比如包含mapping类型的struct 或者 mapping(address=uint256)[] arr.
                    - 在合约内 使用storage存储位置的引用类型变量作为参数，函数可见性只能是internal或者private
                    - 在library内 使用storage存储位置的引用类型变量作为参数，函数可见性没有任何限制
    

51.总结不同数据位置之间的赋值
   - 存储变量 => 存储变量
     值类型 ：创建副本
     引用类型 ：创建副本
   - 存储变量 => 内存变量
     值类型 ：创建副本
     引用类型 ：创建副本
   - 内存变量 => 存储变量
     值类型 ：创建副本
     引用类型 ：创建副本
   - 内存变量 => 内存变量
     值类型 ：创建副本
     引用类型 ：传递指针
   - 存储变量 => 局部存储变量
     值类型：不存在局部值类型存储变量，因为值类型在局部中（即函数中：使用memory存储位置的区域）默认且只能是memory存储位置
     局部存储变量：传递指针
52.字符串修改bytes(str)[0]= bytes1('a') 跟 string memory str = 'a' 区别？
   -修改字符串只能借助bytes,即需要将字符串转换成bytes之后才能修改 类似bytes(str)[0]= bytes1('a')
   -string memory str = 'a'代表的是创建一个新的字符串,一下代码中str的指针会发生改变。
   string memory str = 'a'; 
   str = "b";// 并不能修改str原来的值，而是重新给str分配了指针，指针位置在内存中对应的值为b

53. 固定长度数组也属于引用类型吗？
    - 属于，数组都属于引用类型，数组分为固定长度数组跟动态数组。

54. address常量表示方式？
    contract Demo{
        address public addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;//无需加单引号或者双引号
        address[] public addrs = [0x5B38Da6a701c568545dCfcB03FcB875f56beddC4];
    }

55. uint256[5] arr = [1]跟uint256[5] arr(只声明未赋值的形式) 它们的值分别是什么？
    - 数组值的个数可以少于数组的长度，少的部分用类型的默认值填充，比如uint256 默认值为0，
      但不能大于数组的长度。
    - uint256[5] arr = [1] 值为：[1,0,0,0,0]
    - uint256[5] arr; 值为[0,0,0,0,0]

56. 理解数组常量的懒惰性？
    contract Demo{
        // int8[] public a1 = [1,-1];//错误，因为数组的惰性，数值1的类型uint8,所以必须要将数值1显示转换成int8类型。
        int8[] public a2 = [int8(1),-1];//正确
        function test1(uint256[2] memory arr) pure public {
        }
        function test2() pure public {
            // test1([1,2]);//因为数组的惰性，数值1、2的类型uint8,所以必须要将数值1显示转换成uint256类型。
            test1([uint256(1),uint256(2)]);//正确
        }
    }

57. assert函数的使用？
    - assert(bool) 函数的作用是判断执行的代码是否符合预期
      仅当bool值是true时，代码继续执行，否则会revert
    contract Demo{
    function test1() pure public returns(uint256[] memory temp){
        temp = new uint256[](3);
        temp[0] = 1;
        temp[1] = 2;
        temp[2] = 3;
        assert(temp.length == 2);//会触发revert
        assert(temp[0] == 1);
    }
}
58. 数组能通过修改length属性（即arr.length = 5）来改变数组的长度吗？
    - 不行，无论是固定长度数组还是动态数组都不能通过修改length属性来改变数组的长度
    - 但动态数组可以通过push、pop函数修改数组长度，而固定长度数组没有push、pop函数。
    contract Demo{
        uint256[3] arr1 = [1,2,3];
        uint256[] arr2 = [2,3,4];
        function test() public returns(uint256){
            assert(arr1.length == arr2.length);
            // arr1.length = 1;//Member "length" is read-only and cannot be used to resize arrays.
            // arr2.length = 1;//Member "length" is read-only and cannot be used to resize arrays.
            // arr1.push(4);//固定长度数组没有push方法
            // arr1.pop();//固定长度数组没有pop方法
            arr2.push(5);
            return arr2.length;// 返回4
        }
    }

59. 理解动态数组的push pop函数？
    - 固定长度数组是没有push pop函数的,只有动态数组会有
    - push函数会在数组末尾追加一个数值 数组长度加1
    - pop函数会在数组末尾删除一个数值 数组长度减1
    - push(x) pop()没有任何返回值 

60. delete arr[2] 跟 delete arr的区别？
    - delete arr[2] 表示将指定索引的位置的值重置为类型的默认值 数组长度不会改变
    - delete arr 如果arr是动态数组表示将数组清空 数组长度变为0，如果arr为固定长度数组，所有位置的值都重置为0,数组长度不变
    uint256[3] arr1 = [1,2,3];
    uint256[] arr2 = [2,3,4];
    // 返回值为3 、 0,其中arr1的值为[0,2,3]
    function test() public returns(uint256 len1,uint256 len2){
        delete arr1[0];
        len1 = arr1.length;
        delete arr2;
        len2 = arr2.length;
    }

61. 怎么实现通过删除指定索引位置实现从数组中完全删除？
    - 理解需求 - 因为使用delete arr[2]这种方式只能将指定索引位置的值重置为类型默认值，而不会改变数组的长度
    而这里的要求是将指定索引位置的值完全从数组中删除
    contract Demo{   
        // 假设arr输入值为[1,2,3,4,5]
        function deleteByIndex(uint256[] memory arr) public pure returns(uint256[] memory){        
            arr  = delByIndex(arr,3);
            assert(arr.length == 4);
            assert(arr[0] == 1);
            assert(arr[1] == 2);
            assert(arr[2] == 3);
            assert(arr[3] == 5);
            return arr;
        }
        function delByIndex(uint256[] memory arr,uint256 index_) internal  pure returns(uint256[] memory arr1){
            require(index_ < arr.length,"invalid index");
            arr1 = new uint256[](arr.length - 1);
            for(uint256 index = 0; index < arr.length - 1 ; index++){
                if(index >= index_){
                    arr1[index] = arr[index+1];
                }else{
                    arr1[index] = arr[index];
                }
            }
        }    
    }

62. 数组切片具体用法？ （注意 bytes 如果也支持切片 后续补充）
    - 切片只适用于calldata数据位置的动态数组,同时使用切片函数的返回值也为动态数组类型
    - 格式：arr[start:end] or arr[start:] or arr[:end] 其中start、end分别表示索引
    - arr[start:end] : start -> (end-1) 不包含end
    - arr[start:] : start -> (arr.length -1 )
    - arr[:end] : 0 -> (end-1) 不包含end

63. 数组切片有诸多限制，比如 “切片只适用于calldata数据位置的动态数组,同时使用切片函数的返回值也为动态数组类型”，
    怎么自己实现切片功能？
    function slice(uint256[] memory arr) public pure returns(uint256[] memory){        
        arr  = slice(arr,1,7);
        return arr;
    }
    function slice(uint256[] memory arr,uint256 start,uint256 end) internal  pure returns(uint256[] memory arr1){
        require(start < arr.length && end < arr.length,"invalid index");
        arr1 = new uint256[](end - start);
        for(uint256 index = start; index < end ; index++){
            arr1[index - start] = arr[index];
        }
    } 


64. 十六进制数据0x616263 跟 hex"616263"这两种形式分别可以给哪些类型的变量赋值？
    // bytes public bts2 = 0x616263;//错误 不能使用0x616263这种形式给bytes赋值，但是可以使用hex"616263"
    bytes public bts2 = hex"616263";//正确

    // string public str1 = 0x616263;//错误 不能使用0x616263这种形式给string赋值，但是可以使用hex"616263"
    string public str2 = hex"616263";//正确

    bytes2 public bt1 = 0x6162;//正确 bytesN 类型既能使用0x6162也能使用hex"6162"赋值
    bytes2 public bt2 = hex"6162";//正确

    uint256 public u1 = 0x6162;//正确 整数类型只能使用十六进制0x616263这种形式赋值，hex"6162"不行
    uint256 public u2 = hex"6162";// 错误

    address public addr1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;//正确 地址类型只能使用十六进制0x616263这种形式赋值，hex"6162"不行
    address public addr2 = hex"5B38Da6a701c568545dCfcB03FcB875f56beddC4";// 错误

64. bytes的创建和赋值.
    bytes public bts1 = "abc";//正确
    // bytes public bts2 = 0x616263;//错误 不能使用0x616263这种形式给bytes赋值，但是可以使用hex"616263"
    bytes public bts2 = hex"616263";//正确
    bytes public bts3 = bytes("abc");//正确 这种形式跟bytes public bts1 = "abc";类似
    bytes public bts4 = new bytes(3);//正确 new bytes(uint256)其中的uint256参数表示的bytes的长度，注意跟bytes("abc")这种形式区分开。
    //以下是跟string类型的创建赋值的对比，唯一区别就是string类型不能使用string public str3 = new string(3);
    string public str1 = "abc";//正确
    // string public str1 = 0x616263;//错误 不能使用0x616263这种形式给string赋值，但是可以使用hex"616263"
    string public str2 = hex"616263";//正确
    string public str3 = string("abc");//正确 这种形式跟string public str1 = "abc";类似
    // string public str3 = new string(3);//错误 由于string本身并没有length属性，所以这种方式也是错误的

65. bytes memory bts = "aaaaaa";这种方式在函数中创建可以吗？
   - 可以，在这一点上跟动态数组有所区别，比较如下代码
   function test1() public pure returns(bytes memory){
    //    bytes memory bts = "aaaa"; //正确
    //    bytes memory bts = bytes("aaaa");//正确
    //    bytes memory bts = hex"616263";//正确
       bytes memory bts = new bytes(4);//正确
       return bts;
   }

   function test2() public pure returns(uint8[] memory){
    //    uint8[] memory nums = [1,2,3];//错误
       uint8[] memory nums = new uint8[](3);//正确
    //    uint8[3] memory nums1 = [1,2,3];//正确
       return nums;
   }

66. bytes类型跟 bytes1[]的区别？
   - 可以把bytes理解成bytes1[],它们之间的区别如下：
        - 动态数组在memory存储区域不能动态创建，bytes没有限制
        - bytes 在memory区域虽然可以动态创建(动态数组不行)，即使用bytes memory bts = "abc" 
          但跟动态数组bytes1[]一样不能使用push pop函数
        - bytes 跟 bytes1[] 数据形式不一样,bytes类似bytes1[]数组的紧打包形式，如下：
        bytes : 0x616263
        bytes1[] : [0x61,0x62,0x63]
        function test1() public pure returns(bytes memory,bytes1[] memory){
            bytes memory bts = "abc";
            // bytes1[] memory bts1Arr = [bytes1("a"),bytes1("b"),bytes1("c")];//动态数组在memory存储区域不能使用这种方法创建，bytes没有限制
            bytes1[] memory bts1Arr = new bytes1[](3);
            bts1Arr[0] = "a";
            bts1Arr[1] = "b";
            bts1Arr[2] = "c";
            return (bts,bts1Arr); // 返回值0x616263 / [0x61,0x62,0x63]
        }

        - bytes有concat函数，string也有，但是动态数组(如bytes1[])没有
        function test2() public pure returns(bytes memory ){
            bytes memory bts = "abc";
            return bytes.concat(bts,"a","b");
        }
        
   - bytes的属性跟动态数组bytes1[]完全一致：
        -动态数组的属性包含：length 跟 index,bytes同样包含：
        //注意：获取bytes中指定index的内容返回值类型是bytes1
            同时修改bytes中指定index的内容只能传递bytes1类型
        function test3() public pure returns(bytes1){
            bytes memory bts = "abc";
            return bts[0];
        }
        function test3() public pure{
            bytes memory bts = "abc";
            bts[0] = bytes1("d");
        }

   - bytes的方法跟动态数组bytes1[]基本一致：
       - bytes包含动态数组的所有方法：pop、push、delete bts(完全删除)、delete bts[0](根据index删除)、bts[start:end](切片)
       - bytes还有一个特有的方法即bytes.concat(),动态数组并没有：
       function test2() public pure returns(bytes memory ){
            bytes memory bts = "abc";
            return bytes.concat(bts,"a","b");
        }

67. bytes/bytesN 跟 string怎么互相转换?
    - bytes <=> string 使用bytes(string) 跟 string(bytes)即可。
    function test1() public pure returns(string memory str){
      bytes memory bts = "abc";
      str = string(bts); 
    }
    function test2() public pure returns(bytes memory bts){
      string memory str = "abc";
      bts = bytes(str); 
    }

    - bytesN <=> string 
    // bytes4 转换到 string 需先将bytesN转换成bytes,再将bytes转换成string。
    function test1() public pure returns(string memory str){
      bytes4 bts4 = "abcd";
      bytes memory temp = new bytes(bts4.length);
      for(uint256 i = 0;i< temp.length;i++){
         temp[i] = bts4[i];
      }
      str = string(temp); 
    }

    // string 转换到bytes4, 需先将string转换成bytes,再使用bytesN(bytes)方法将bytes转换成bytesN.
    // 注意bytesN是不能通过index属性修改bytesN的值，即使用bytesN[0] = bytes1("a")会报错。只能通过index获取值。
    function test2() public pure returns(bytes4 bts4){
      string memory str = "abcd";
      bytes memory bts = bytes(str);
      bts4 = bytes4(bts);
    }

68. 比较两个bytes是否相等？
    - 可以借助keccak256(bytes)函数来实现：
    function test() public pure returns(bool result){
      bytes memory bts1 = "abc";
      bytes memory bts2 = "a" "bc";
      result = keccak256(bts1) ==  keccak256(bts2);
    }
    - 延伸1：怎么比较两个string是否相等？
        -需将string转换成bytes,再借助keccak256(bytes)来实现判断
            同时将string转换成bytes有两种形式：
            第一种：使用bytes(string )
            第二种：使用abi函数，如abi.encodePack(string)
           
69. string 跟 bytes的关系？
    - string没有任何自己的属性，包括length、index,都需要借助bytes(即将string转换成bytes)
    - string有一个concat()方法，同时支持delete str ,但没有pop 、push 、delete index、str[strat:end]等方法
    - 延伸：可否借助bytes实现string的pop 、push 、delete index、str[strat:end]等方法

    string public str = "abc";
    //借助bytes 实现string类型 push,注意：bytes.push(x) 跟 bytes.pop()函数没有返回值
    function strPush() public{
      bytes(str).push("d");
    }
    //借助bytes 实现string类型pop,注意：bytes.push(x) 跟 bytes.pop()函数没有返回值
    function strPop() public{
      bytes(str).pop();
    }
    // 无须借助bytes 
    function strDelete() public{
      delete str;
    }
    //借助bytes 实现string类型delete index
    function strDeleteInde() public{
      delete bytes(str)[0];
    }
    //借助bytes 实现string类型slice(切片)
    function strSlice(string calldata strParam) public pure returns(string memory){
     bytes memory bts = bytes(strParam)[0:5];
     return string(bts);
    }  

70. bytesN 到bytes相互转换？
    - 将bytes转换成bytesN,直接使用bytesN(bytes)即可
    function test1() public pure returns(bytes4 bts4){
      bytes memory bts = "abc";
      bts4 = bytes4(bts);
    }
    - 将bytesN转换成bytes,不能使用bytes(bytesN)
    function test2() public pure returns(bytes memory bts){
      bytes4  bts4 = "abc";
      // bts = bytes(bts4);//TypeError: Explicit type conversion not allowed from "bytes4" to "bytes memory".
      bts = new bytes(bts4.length);
      for(uint256 i = 0;i< bts4.length;i++){
         bts[i] = bts4[i];
      }
    }

71. string.concat() 跟 bytes.concat()区别?
    - 您可以使用string.concat连接任意数量的string值。 该函数返回类型为string， 
      如果您想使用不能隐式转换为string的其他类型的参数，需要先将它们转换为string。
    - bytes.concat 函数可以连接任意数量的 bytes 或 bytes1 ... bytes32值.该函数返回一个bytes类型，
      如果您想使用字符串参数或其他不能隐式转换为bytes的类型，您需要先将它们转换为 bytes 或 bytes1 /.../ bytes32。


72. mapping类型在合约函数中以及library函数中可以作为返回值吗？
    - mapping 类型不能作为函数返回值，无论是合约中函数还是library函数中。
    contract Demo{
    // function test() internal  returns(mapping(address => uint256) storage){
    // }
    }
    library MyLib{
    // TypeError: This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
    // function test() public  returns(mapping(address => uint256) storage){
    // }
    }

73. mapping类型是否支持delete mapping跟delete mapping[key] 操作？
    -mapping支持delete mapping[key],但是不支持delele mapping
    mapping (address => uint256) balances; 
    function set(uint256 amount) public {
        balances[msg.sender] = amount;
    }
    function del1() public{
        delete balances[msg.sender];//正确
    }
    function del2() public{
        // delete balances; // 错误
    }

74. mapping 有length index属性吗？ mapping的key可以重复吗？
    - mapping没有length以及index属性，mapping 的key不可重复
      如果想mapping中插入已存在的key,只会产生覆盖修改
    - 延伸：基于mapping 没有length、index属性，所以需要手动实现可迭代mapping ,怎么迭代mapping? 如下
    contract Demo{
        mapping (address => uint256) balances; 
        mapping (address => bool) insertedKeys;
        address[] keys;
        function set(address addr_,uint256 amount_) public {
            balances[addr_] = amount_;
            // 1.检查
            if(!insertedKeys[addr_]){
                // 2.修改检查条件
                insertedKeys[addr_] = true;
                // 3.执行操作
                keys.push(addr_);
            }
        }
        // 遍历mapping，找出指定金额对应的地址
        function check(uint256 amount_)  public view returns(address){
            for (uint256 i = 0;i < keys.length;i++){
                if(amount_ == balances[keys[i]]){
                    return keys[i];
                }
            }
            return address(0);
        }  
    }
    -延伸：防止重入攻击
    - 如上代码步骤：1.检查判断条件 2.修改条件 3.执行操作

75. struct数据有几种生成方式？
    contract Demo{
        struct Book{
            string name;
            string author;
            uint256 bookid;
        } 
        uint256 index;
        function test() public returns(Book memory,Book memory,Book memory) {
            // 第一种方式 
            // 数据顺序必须跟Book类型中定义的一致
            Book memory book1 = Book(unicode"java 高级变成","tiger",++index);
        
            //第二种方式
            Book memory book2 = Book({
                name:unicode"solidity 高级编程",
                author: "tiger",
                bookid: ++index
            });

            // 第三种方式
            Book memory book3 ;
            book3.author = "tiger";
            book3.bookid = ++index;
            book3.name = unicode"pythod 高级编程";
            return (book1,book2,book3); 
        }
    }
    -延伸：第三种生成方式可以在存储区域创建吗？
    - 不能，第一 第二种可以在存储区域创建，第三中只能在内存区域创建数据
    contract Demo{
        struct Book{
            string name;
            string author;
            uint256 bookid;
        }
        uint256 index;
        // 第一种方式
        Book public book1 = Book(unicode"java 高级变成","tiger",++index);
        // 第二种方式
        Book public book2 = Book({
            name:unicode"solidity 高级编程",
            author: "tiger",
            bookid: ++index
        });
        // 第三种方式 只能定义，不能创建数据
        Book public book;
        // book.author ;// 错误 ParserError: Expected identifier but got '='
        // book.bookid = ++index;
        // book.name = unicode"pythod 高级编程";

        // 第三种方式只能在内存区域创建数据
        function test() public {
            book.author = "tiger";
        }
    }

76. struct包含delete book.name 以及 delete book方法吗？
    - struct中，这两种操作都包含
    - 其中delete book.name 跟 数组delete arr[0]类似，只是删除位置的数据（即将指定位置的数据重置为默认值）
    - delete book 跟 数组 delete arr效果完全不同，数组是完全删除清空，而struct只是将所有位置的数据全部重置为默认值
    contract Demo{
        struct Book{
            string name;
            string author;
            uint256 bookid;
        }
        uint256 index;
        Book public book = Book(unicode"java 高级变成","tiger",++index);

        function del1() public {
            delete book.author;// 将struct指定属性重置了默认值
        }
        function del2() public {
            delete book;// 将struct所有属性重置了默认值 
        }
    }

77. struct在内存区域使用memory存储位置跟storage存储位置 gas消耗区别？
    - struct在内存区域使用storage存储位置会比使用memory存储位置更省gas,因为只创建了一次拷贝，分析代码如下：
    - 问题 : 将数据传递给返回值不管数据类型以及数据存储位置怎样 都会创建拷贝吗？
    contract Demo{
        struct Book{
            string name;
            string author;
            uint256 bookid;
        }
        uint256 index;
        Book public book = Book(unicode"java 高级变成","tiger",++index);
        // 8403 gas 
        function test1() public view returns(string memory){
            Book memory book1 = book;//book -> book1 创建一次拷贝
            return book1.name; // book1.name -> 返回值 创建一次拷贝
        }
        // 3437 gas 
        function test2() public view returns(string memory){
            Book storage book1 = book; //book -> book1 未创建拷贝，只是传递引用
            return book1.name;// book1.name -> 返回值 创建一次拷贝
        }
    }

78. 怎么实现将任意数字转换成字符串？
    contract Demo {
        // 第一种方式 将数字0-9转换成string 0-9
        function toStr(uint8 value) public pure  returns(string memory){
            require(value < 10,"error value");
            bytes memory alphabet = "0123456789";
            bytes1 b1 = alphabet[value];
            bytes memory bs = new bytes(1);
            bs[0] = b1;
            return string(bs);
        }

        // 第一种方式 将数字0-9转换成string 0-9
       function toStr1(uint256 value) public pure returns(string memory){
            bytes memory alphabet = "0123456789abcdef";
            bytes32 data = bytes32(value);
            bytes memory bts = new bytes(1);
            uint256 index = data.length -1 ;
            bts[0] = alphabet[uint8(data[index] & 0x0f)];
            return string(bts);
        }
    
        // 借助toStr1或者toStr方法，将任意数字转换成字符串
        function toStr2(uint256 value) public pure returns(string memory str){
            if(value == 0)  return "0";
            while(value != 0){
                uint256 r = value % 10;
                value = value / 10;
                str = string.concat(toStr1(r),str);
            }
        }
    }

79. 隐式转换发生的场景以及需要符合哪些条件？
    -隐式转换发生场景包括三个：赋值、函数传参、表达式
    -隐式转换发生必要条件：
     1.必须值类型
     2.发生隐式转换的类型必须是目标类型的子集（即只能由小变大），交集是不行的

    contract Demo{
        // 隐式转换发生场景一：赋值
        uint8 a = 8;
        uint16 a1 = a; // 正确 uint8属于uint16的子集
        // int16 a2 = a;// 错误 uint8不属于int16的子集，而是int16的交集
        // 整型字面常量赋值过程也可能发生隐式转换：如下：
        // 数字10默认是uint8类型，由uint8类型隐式转换成uint256类型
        uint256 a3 = 10;

    
        // 隐式转换发生场景二：函数传参
        function test1(uint256 value) public pure returns(uint256){
            return ++value;
        }
        function test2() public pure returns(uint256){
            // return test1(1);//正确 整型字面常量传参过程也发生隐式转换
            uint8 num = 8;
            return test1(num);// 正确
        }

        // 引用类型不会发生隐式转换
        function test3(uint256[3] memory value) public pure returns(uint256){
            return value[0];
        }
        function test4() public pure returns(uint256){
            // return test1([1,2,3]);//错误 [1,2,3] 字面常量默认为固定长度数组uint8[3]类型，属于引用类型，故不能隐式转换为uint26[3]
       
            // uint8[3] memory num = [1,2,3];
            // return test3(num);// 错误 uint8[3]类型，属于引用类型,故不能隐式转换为uint26[3]

           return test3([uint256(1),uint256(2),uint256(3)]); // 正确
        }

        // 隐式转换发生场景三：表达式
        uint16 b = 8;
        // 表达式（b+2）发生了隐式转换，过程如下：
        // b的类型是uint16,数字2的默认类型的是uint8,会隐式转换为uint16
        uint16 b1 = b + 2; 
    }


80. 隐式转换跟显示转换的区别以及相同之处？
    -隐式转换只支持同类型转换 如uint8->uint16 ,同时只能由小类型到大类型（即转换类型必须是目标类型的子集），
     显示转换同时可以由大类型到小类型 如uint16->uint8 ，但是会发生截断（即转大小）
    -显示转换支持部分跨类型转换（即转类型）,但是不同类型的bit数必须一致， bytes -> bytesN除外 比如：
     uint8 -> bytes1 或者 bytes1 -> uint8、（uint8、bytes1都是8bit）
     bytes -> bytesN、
     address - > uint160 或 address - > bytes20、（address、uint160、bytes20都是20bit）
     uint160 - > address 或 uint160 - > bytes20、
     bytes20 - > address 或 bytes20 - > uint160等
     uint8 -> int8 或者 int8 -> uint8

81. 比较uint（int）类型之间从大到小的显示转换的截断情况跟bytesN类型之间从大到小的显示转换的截断情况有什么不同？ 
    - 整型由大到小  从左边舍弃(截断),由小到大  从左边增加
    - bytesN由大到小  从右边舍弃(截断),由小到大  从右边增加
    contract Demo{
        uint16 public  a = 0x5678;//0x5678 => 22136
        // 整型由大到小  从左边舍弃
        // 0x5678 => 0x78 => 120
        uint8 public a1 = uint8(a);// 120

       // 整型由小到大  从左边增加
       // 0x5678 => 0x0000 5678 => 22136
       // uint32 public a2 = a;// 正确 符合隐式转换的条件
       uint32 public a2 = uint32(a);// 正确 22136


       bytes2 public b = 0x5678;
       // bytesN由大到小  从右边舍弃
       // 0x5678 => 0x56 
       bytes1 public b1 = bytes1(b);// 0x56

       // bytesN由小到大  从右边增加
       // 0x5678 => 0x567800 
       bytes3 public b2 = bytes3(b);// 0x567800
    }

82. uintN跟bytesN之间的相互转换  
    -  bytesN -> uintN 应该先转类型，再转大小
    -  uintN -> bytesN 应该先转大小，再转类型
    contract Demo{
       /*
        * bytesN -> uintN 应该先转类型，再转大小
        */
        bytes2 public b = 0x5678;
        // 先转大小(bytes2->bytes4)，再转类型(bytes4->uint32)
        // 0x5678 -> 0x5678 0000 -> 1450704896
        function toUint32_1() public view returns(uint32){
            bytes4 b1 = b;
            return uint32(b1);//1450704896
        }

        //先转类型(bytes2->uint16)，再转大小(uint16->uint32)
        // 0x5678 -> 0x5678 -> 0x0000 5678
        function toUint32_2() public view returns(uint32){
            uint16 b1 = uint16(b);
            return uint32(b1); // 22136
        }

    
       /*
        * uintN -> bytesN 应该先转大小，再转类型
        */
        uint16 public a = 0x5678;
        //先转大小(uint16->uint32)，再转类型(uint32->bytes4)
        // 0x5678 -> 0x0000 5678 -> 0x0000 5678
        function toBytes4_1() public view returns(bytes4){
            uint32 a1 = a;
            return bytes4(a1);
        } 

        // 先转类型(uint16->bytes2)，再转大小(bytes2->bytes4)
        // 0x5678 -> 0x5678 -> 0x5678 0000
        function toBytes4_2() public view returns(bytes4){
            bytes2 a1 = bytes2(a);
            return bytes4(a1);
        }    
    }


83. bytes跟bytesN之间相互转换 、 bytes跟address之间相互转换
    - bytes跟bytesN之间相互转换 参考此文档67条
    - bytes跟address之间相互转换 参考次文档38条


84. 如何快速计算出数字的补码？  
    int8 的取值范围用十六进制表示为 -0x80(-128) - 0x7f(127).
    //第一种方式通过原码-》反码 -》补码
    // 0x7f -> 0111 1111(整数原、反、补一致)
    int8 public a3 = 0x7f; 
    // -0x7f -> 1111 1111(原) -> 1000 0000(反) -> 1000 0001(补) 
    int8 public a3 = -0x7f; 
    // -0x80 -> 1 1000 0000(原) ->  1 0111 1111(反) -> 1 1000 0000(补) -> 1000 0000(首位舍弃)
    int8 public a2 = -0x80;

    //第二种方式通过 补码计算真值的规则 反推。
    首位为1开头的补码所代表的正数跟负数的真值计算规则为：
    如：补码 1000 1100
    负数：1 * 2 **2 + 1 * 2 ** 3 - 1 * 2 ** 7 = 4 + 8 - 128 = -116
    正数：1 * 2 **2 + 1 * 2 ** 3 + 1 * 2 ** 7 = 4 + 8 +128 = 140
    // -116 = 12(1100) - 128 = 1000 1100 
    int8 public a3 = -116; 
    // 140 = 128 + 12(1100) = 1000 1100  
    uint8 public a3 = 140; 
    // -0x80 = -128 = 0(0000) - 128 = 1000 0000
    int8 public a2 = -0x80;
    // 0x7f = 127 = 127(111 1111) + 0 = 0111 1111
    int8 public a2 = 0x7f;

85. uint8 跟 int8之间是可以相互转换的
   uint8的取值范围是0000 0000 - 1111 1111 (可以拆分为两个区间0000 0000 - 0111 1111 跟 1000 0000 - 1111 1111)
   int8的取值范围是1000 0000 - 0111 1111 （可以拆分为两个区间1000 0000 - 1111 1111跟0000 0000 - 0111 1111 ）
   因为负数是用补码表示的，
   其中区间0000 0000 - 0111 1111在uint8 跟 int8中都是表示0 - 127
   同时因为1000 0000 - 1111 1111（注意理解 1111 1111（-1的补码表示） 跟 0000 0000（0的补码）是两个相邻的数）
   在int8中表示 -128 - -1 ， 而在uin8中也可以表示为 128 - 255
   因此这两种类型包含的补码是完全一致的,所以它们是可以转换的，
   注意，需要注意变量类型，因为在不同的变量类型中可以表示不同的值：如
   1111 1111 在uint8中表示255 而在int8中表示-1


86. 十六进制字面常量hex"11" 跟 0xff分别可以转换为哪些类型？
   - hex"61" 支持的类型是 bytesN、bytes、string 
     注意 使用这种方式必须成对出现（即个数必须是偶数）
   - 0xff 支持的类型是uintN、intN、bytesN
    contract Demo{
        uint8 a = 0xff;
        // uint8 a1 = hex"ff";

        int8 b = 0x7f;
        // int8 b1 = hex"7f";

        bytes1 c = 0x61;
        bytes1 c1 = hex"61";

        string d = hex"61";
        // string d1 = 0x61;

        bytes e = hex"ff";
       // bytes e1 = 0xff;    


       // 个数必须是偶数
       // bytes8 bts = hex"123";//错误 ParserError: Expected even number of hex-nibbles.
    }
87. 使用call跟delegatecall多层调用（测试实例二层）修改的分别是哪里的存储？
    // SPDX-License-Identifier: GPL-3.0
    // 测试流程 call - call(其他3种情况做类似修改即可)：将demo1中的addr1.delegatecall(sign)-addr1.call(sign)、demo2中已是addr.call(sign)所以无需修改。
    // call - call:修改的是demo3中num 
    // delegatecall - delegatecall:修改的是demo1中num
    // call - delegatecall：修改的是demo2中num
    // delegatecall - call：修改的是demo3中num
    pragma solidity >=0.7.0 <0.9.0;
    contract Demo1{
        uint256 public num;
        function setNum(address addr1,address addr2) public returns(uint256 result){
            bytes memory sign =  abi.encodeWithSignature("setNum(address)",addr2);
            (bool success,bytes memory data) = addr1.delegatecall(sign);
            require(success,"call error");
            result = abi.decode(data,(uint256));
        }
    }
    contract Demo2{
        uint256 public num;
        function setNum(address addr) public returns(uint256 result){
            bytes memory sign =  abi.encodeWithSignature("setNum()");
            (bool success,bytes memory data) = addr.call(sign);
            require(success,"call error");
            result = abi.decode(data,(uint256));
        }
    }
    contract Demo3{
        uint256 public num;
        function setNum() public returns(uint256){
            num = 111;
            return num;
        }
    }
88. 可升级只能合约的编写？
    合约升级的底层原理参考https://aandds.com/blog/eth-delegatecall.html
    具体示例(基于openzeppelin实现)如下：
    1.透明代理(Transparent Proxy Pattern)
      - 合约结构参照https://github.com/enzo5188/solidity_messy.github
      - 操作测试流程如下：
        1. 部署demoV1, 得到logic contract address
        2. 调用demoV1 的辅助方法getSign获取到initialize(uint256)的signdata
        3. 部署myProxy合约得到代理合约地址，参数_logic为logic contract address，
           参数initialOwner为proxyAdmin的owner地址（外部地址),参数_data为signdata.
        4. 调用myProxy的getUint256Slot（输入0）可以得到demoV1中number的值，
           调用myProxy的getAddressSlot，分别传入如下参数可获得对应的值：
            0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;//获取到的是当前逻辑合约的地址
            0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;//获取到的是proxyAdmin合约的地址
        5. 调用demoV1 的辅助方法getSign获取到setNumber()的signdata
        6. 在代理合约中通过低级交互calldata方式传入上一步获取的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照demov1中setNumber的逻辑）
        7. 调用myProxy的getAddressSlot,并传入0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103，
           获取到proxyAdmin合约的地址,并通过remix的at address功能将proxy合约加载出来。
        8. 将demov2部署得到demoV2合约地址，并得到demov2中initialize(uint256)的signdata.
        9. 调用proxyAdmin中的upgradeAndCall函数，参数proxy出入代理合约地址，implementation传入demov2的地址，
           data传入上一步得到的signdata，之后执行。
        10.调用myProxy的getAddressSlot,并传入0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
           获取到值已经是demov2的地址。
        11.在代理合约中再次通过低级交互calldata方式传入setNumber()的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照demov2中setNumber的逻辑）
        12.升级成功。
                
    2.UUPS代理(Universal Upgradeable Proxy Standard)
        - 合约结构参照https://github.com/enzo5188/solidity_messy.github
        - 操作测试流程如下：
        1. 部署demoV1, 得到logic contract address,
           并通过demoV1中的getSign函数获取initialize(address,uint256)的signdata,
           函数initialize(address initialOwner,uint256 _number)中initialOwner为即将部署的代理合约的owner地址。
        2. 部署代理合约myProxy，参数implementation 为逻辑合约地址，_data为上一步得到的signdata。
        3. 调用myProxy的getUint256Slot（输入0）可以得到demoV1中number的值，
           调用myProxy的getAddressSlot，分别传入如下参数可获得对应的值：
           0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;//获取到的是当前逻辑合约的地址
        4. 调用demoV1 的辅助方法getSign获取到setNumber()的signdata
        5. 在代理合约中通过低级交互calldata方式传入上一步获取的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照demov1中setNumber的逻辑）
        6. 部署demoV2, 得到demov2的地址,并通过demoV2中的getSign函数获取initialize(uint256)的signdata，备用。
        7. 通过demoV2中的helper函数获取升级函数upgradeToAndCall(address,bytes)的signdata,
           注意 upgradeToAndCall(address,bytes) 中address为上一步得到的demoV2的地址，bytes为上一步得到的signdata.
        8. 代理合约中通过低级交互calldata方式传入上一步得到的升级函数upgradeToAndCall(address,bytes)的signdata并调用，
        9.调用myProxy的getAddressSlot,并传入0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
           获取到值已经是demov2的地址。
        10.在代理合约中再次通过低级交互calldata方式传入setNumber()的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照demov2中setNumber的逻辑）
        11.升级成功。


    3.Beacon代理（openzeppelin的beacon代理不支持使用proxyAdmin修改bencon的功能，以下代码参照透明代理的实现，加入了使用proxyAdmin修改bencon的功能） 
        - 合约结构参照https://github.com/enzo5188/solidity_messy.github
        - 操作测试流程如下：
        1. 部署demoV1, 得到logic contract address,
        2. 部署myBeaconV1，得到myBeaconV1的地址，其中参数implementation为demoV1的地址，initialOwner为myBeaconV1的owner地址。
        3. 并通过demoV1中的getSign函数获取initialize(uint256)的signdata
        4. 部署代理合约myProxy，参数beacon 为myBeaconV1的地址，data为上一步得到的signdata,initialOwner为proxyAdmin合约的owner地址(外部地址)
        5. 调用myProxy的getUint256Slot（输入0）可以得到demoV1中number的值，
           调用myProxy的getAddressSlot，分别传入如下参数可获得对应的值：
            0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;//获取到的是当前beacon的地址
            0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;//获取到的是proxyAdmin合约的地址
        4. 调用demoV1 的辅助方法getSign获取到setNumber()的signdata
        5. 在代理合约中通过低级交互calldata方式传入上一步获取的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照demov1中setNumber的逻辑）
        6. 部署demoV2, 得到demov2的地址.
        7. 在myBeaconV1中调用upgradeTo函数，其中newimplementation传入demoV2的地址，执行。
        9.调用myProxy的getAddressSlot,并传入0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
           获取到值已经是demov2的地址。
        10.在代理合约中再次通过低级交互calldata方式传入setNumber()的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照demov2中setNumber的逻辑）
        11. 升级成功。

        12. 接下来是测试proxyAdmin的功能，
            调用myProxy的getAddressSlot,并传入0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103，
            获取到proxyAdmin合约的地址,并通过remix的at address功能将proxy合约加载出来。
        13 .部署MybeaconV2 , 得到myBeaconV2的地址，其中参数implementation为demoV1的地址，initialOwner为myBeaconV2的owner地址。
        14 .调用proxyAdmin中的upgradeBeaconToAndCall函数，参数proxy出入代理合约地址，参数beaconAddress传入MybeaconV2的地址，
            参数data传入0x即可。之后执行。
        15.调用myProxy的getAddressSlot,并传入0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50,
           获取到值已经是beaconv2的地址。
        16.在代理合约中再次通过低级交互calldata方式传入setNumber()的signdata并调用，
           之后再调用myProxy的getUint256Slot,发现number的值已经发生改变（按照beaconv2中demoV1的逻辑）

89. 使用remix 有哪些注意的地方？     
    1.remix ide 中 at address 功能需要先选中合约。。。。。。。
    2.goerli测试网络 已经停用
    3.remix ide 如果选择的evm 在remix vm(shanghai)之前，编译器版本必须少于等于0.8.19
    4.remix ide 在线版本很不稳定
    5.remix dgit中只能使用https的远程分支，不能使用ssh格式的 , 同时在remix中使用dgit不需要关闭vpn
    6.vscode 跟 git base控制台必须关闭vpn,同时只能使用ssh格式的。


    合约数据存储布局？
    内联汇编？
72. abi.encode 跟 abi.encodePacked 区别
16. indexed 




   


