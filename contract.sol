// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenAirdrop {
    address public mainAddress;
    mapping(address => uint) public balances;//构造了一个数据结构，使我可以通过输入地址来查找对应的余额

    constructor(address _mainAddress) {//构造函数，作用是将一个参数为_mainAddress类型设置为主地址address，并将一个地址赋值给_mainAddress并取名为mainAddress
        mainAddress = _mainAddress;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;//+=就是将右边加上左边得到左边新值，其中deposit功能是记录将别人发给主地址的币加到主地址的总余额中去
    }

    function collectTokens(address[] calldata addresses, uint[] calldata amounts) external {
        //注意上面这里设置了addresss和amounts数组，类型分别设置为address[]和uint[]
        require(addresses.length == amounts.length, "Invalid input lengths");
        //require是断言语句，当数组addresses和数组amounts长度相等时就可以继续执行下面代码，不然就输出：Invalid input lengths
        for (uint i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Invalid address"); // 添加地址验证，避免转移到无效地址，无效地址表示为address(0)
            balances[mainAddress] += amounts[i];//mainAddress=mainAddress+amount[i]，其功能是将其分支地址上的余额加到主地址的余额中
            balances[addresses[i]] -= amounts[i];//address[i]=addresses[i]-amount[i]，其功能是将其分支地址上送出去的余额减从其总值中减掉
        }
    }

    function withdrawGasFees() external {
        require(msg.sender == mainAddress, "Unauthorized"); // 添加权限控制，只有主地址可以提取燃气费用
        uint gasFee = gasleft() * tx.gasprice;//计算消耗的gas费，其中消耗的gas量是可以通过函数gasleft()来获取，gas单价可以通过tx.gasprice变量获取
        require(balances[mainAddress] >= gasFee, "Insufficient balance");
        //构造一个断言语句，要求主地址余额必须大于等于所需gas费，否则不能运行下面代码
        balances[mainAddress] -= gasFee;
        (bool success, ) = payable(mainAddress).call{value: gasFee}(""); 
        // 使用安全的转账函数进行转账操作,value: gasFee 表示在转账时发送的以太币数量为 gasFee;
        //返回值 (bool success, ) 是一个元组（Tuple），通过这个语法，我们可以同时将 call 函数的返回值中的第一个布尔值部分（表示转账是否成功）赋值给 success 变量
        require(success, "Transfer failed");//这段代码，我们要求转账操作必须成功，否则合约执行将被中止，并抛出一个错误消息提示转账失败。
    }
}