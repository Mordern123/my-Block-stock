// SPDX-License-Identifier: MIT
pragma solidity >=0.5.22 <0.9.0;
//import "./Getstock.sol";

contract UserManagement {
    
    mapping(string => userinformation) public person;
    
    struct userinformation{
        string user_name;       //使用者名稱
        string user_password;   //使用者密碼
        string user_grade;      //使用者學年
        string user_major;      //使用者科系
        uint user_cash;         //使用者現金
        uint user_stockvalue;   //使用者股票價值
    }
    //使用者註冊
    function setUser(string memory _useraccount, string memory user_name, string memory user_password, string memory user_grade, string memory user_major) public{
        person[_useraccount] = (userinformation(user_name, user_password, user_grade, user_major, 2000000, 0));     
    }
    //觀看註冊是否成功
    function get_User(string memory _useraccount) public view returns(string memory, string memory, string memory, string memory, string memory, uint, uint){
        userinformation memory ui = person[_useraccount];
        return (ui.user_name, _useraccount, ui.user_password, ui.user_grade, ui.user_major, ui.user_cash, ui.user_stockvalue);
    }
    //是否存在此帳號
    function user_IsExist(string memory _useraccount) public returns(bool) {
        return bytes(person[_useraccount].user_name).length != 0;
    }
    //拿到使用者的錢
    function get_UserMoney(string memory _useraccount) public returns(uint, uint){
        return (person[_useraccount].user_cash, person[_useraccount].user_stockvalue);
    }
    //更新使用者的錢
    function update_UserMoney(string memory _useraccount, uint cash, uint stockvalue) public{
        person[_useraccount].user_cash = cash;
        person[_useraccount].user_stockvalue = stockvalue;
    }
    int a=0;//測試登入機制
    //使用者登入
    function input_User(string memory account, string memory password) public{
        if(keccak256(abi.encodePacked(password)) == keccak256(abi.encodePacked(person[account].user_password))){
            //登入成功
            a=1;
        }
        else{
            //密碼錯誤
            a=2;
        }
    }
    //測試登入機制
    function geta() public view returns(int){
        return a;
    }
}