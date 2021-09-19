// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract UserManagement {
    
    mapping(string => userinformation) public person;
    
    struct userinformation{
        string user_name;       //使用者名稱
        string user_password;   //使用者密碼
        string user_grade;      //使用者學年
        string user_major;      //使用者科系
        int user_cash;         //使用者現金
        int user_stockvalue;   //使用者股票價值
        int user_RateOfReturn; //使用者投資報酬率
        uint user_calltime;
    }
    
    // 所有使用者
    bytes32[] public all_Useraccount;
    
    //使用者註冊
    function setUser(string memory _useraccount, string memory user_name,
    string memory user_password, string memory user_grade, string memory user_major) public{
        bytes32 bytes_useraccount;
        assembly {
            bytes_useraccount := mload(add(_useraccount, 32))
        }
        bool user_state = true;
        for(uint i = 0 ; i < all_Useraccount.length ; i++) {
            if(all_Useraccount[i] == bytes_useraccount){
                user_state = false;
            }
        }
        if(user_state == true){
            all_Useraccount.push(bytes_useraccount);  
            person[_useraccount] = (userinformation(user_name, user_password, user_grade,
            user_major, 2000000, 0, 0, block.timestamp));
        }
    }
    
    //觀看註冊是否成功
    function get_User(string memory _useraccount, string memory user_password) public view returns(string memory){
        
        userinformation memory ui = person[_useraccount];
        if(keccak256(abi.encodePacked(user_password)) == keccak256(abi.encodePacked(person[_useraccount].user_password))){
            //登入成功
            return "success";
        }
        else{
            //密碼錯誤
            return "fail";
        }
        
        // return (ui.user_name, _useraccount, ui.user_password, ui.user_grade, ui.user_major, ui.user_cash, ui.user_stockvalue, ui.user_RateOfReturn, ui.user_calltime);
    }

    function getMoney(string memory _useraccount) public view returns(int, int){
        int cash = person[_useraccount].user_cash;
        int value = person[_useraccount].user_stockvalue;
        return (cash, value);
    }
    
    //觀看所有使用者
    function get_allUser() public view returns(bytes32[] memory){
        //bytes32轉string
        // string memory convertuserID;
        // uint8 i = 0;
        // while(i < 32 && all_Useraccount[i] != 0) {
        //     i++;
        // }
        // bytes memory bytesArray = new bytes(i);
        // for (i = 0; i < 32 && all_Useraccount[i] != 0; i++) {
        //     bytesArray[i] = all_Useraccount[i];
        // }
        // convertuserID = string(bytesArray);
        return all_Useraccount;
    }
    
    //在Getstock檢查是否存在此帳號
    function user_IsExist(string memory _useraccount) public returns(bool) {
        return bytes(person[_useraccount].user_name).length != 0;
    }
    
    //在Getstock拿到使用者的錢
    function get_UserMoney(string memory _useraccount) public returns(int, int){
        return (person[_useraccount].user_cash, person[_useraccount].user_stockvalue);
    }
    
    //在Getstock拿到使用者股票價值
    function get_UserStockValue(string memory _useraccount) public returns(int){
        return (person[_useraccount].user_stockvalue);
    }
    
    //更新使用者的錢
    function update_UserMoney(string memory _useraccount, int cash, int stockvalue) public{
        person[_useraccount].user_cash = cash;
        person[_useraccount].user_stockvalue = stockvalue;
    }
    
    //更新使用者的股票價值
    function update_UserStockValue(string memory _useraccount, int stockvalue) public{
        person[_useraccount].user_stockvalue = stockvalue;
    }
    
    //更新使用者的投資報酬率
    function update_UserRateOfReturn(string memory _useraccount) public{
        person[_useraccount].user_RateOfReturn = (person[_useraccount].user_stockvalue + person[_useraccount].user_cash)/2000000;
    }

    int a=0;//測試登入機制
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