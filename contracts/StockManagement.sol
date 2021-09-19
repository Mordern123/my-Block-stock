// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./UserManagement.sol";

//儲存交易者資料
contract StockManagement {
    
    UserManagement UM; //global
    
    constructor(address um_addr) public { 
        UserManagement um = UserManagement(um_addr); //get contract
        UM = um;
    }
    
    //股票交易
    mapping(string => mapping(string => stockTxn)) public stock;
    struct stockTxn{
        string stock_Name;     //公司名稱
        int stock_NowPrice;    //股票價格
        int stock_Number;      //股票數量
        uint stock_calltime;   //購買股票時間
    }
    
    // +所有股票價格mapping
    mapping(string => StockData) public allStockData;//股票代號去找股票資料
    struct StockData {
        string stock_Name;      //公司名稱
        int stock_NowPrice;    //股票價格
    }
    
    // 使用者購買的股票mapping
    mapping(string => bytes32[]) public buy_allStockData;
    
    // +所有股票id array(拿來看現在有哪些股票要搜尋)
    bytes32[] public search_allStockId;
    
    // +所有使用者有購買的股票array
    bytes32[] public buy_allStockId;

    // +使用者搜尋股票FUNCTION(新增id array元素 + 篩選去除相同元素)
    function search_StockId(string memory stockId) public {
        bytes32 bytes_stockId;
        assembly {
            bytes_stockId := mload(add(stockId, 32))
        }
        
        bool stock_state = true;
        for(uint i = 0 ; i < search_allStockId.length ; i++) {
            if(search_allStockId[i] == bytes_stockId){
                stock_state = false;
            }
        }
        if(stock_state == true){
            search_allStockId.push(bytes_stockId);
        }
    }
    
    // +取得需要更新股票陣列FUNCTION
    function get_search_allStockId() public view returns(bytes32[] memory){
        return search_allStockId;
    }
    
    // +更新所有股票值function(鏈下觸發)
    function update_StockData(string memory stockId, string memory stock_Name, int stock_NowPrice) public{
        allStockData[stockId].stock_Name = stock_Name;
        allStockData[stockId].stock_NowPrice = stock_NowPrice;
    }
    
    //目前mapping裡該股票的資訊
    function inputStockId_getStockData(string memory stockId) public view returns(string memory, int){
        StockData memory S = allStockData[stockId];
        return (S.stock_Name, S.stock_NowPrice);
    }

    //儲存股票資料
    function set_User_StockId(string memory account, string memory stockId, string memory stock_Name, int stock_NowPrice, int stock_Number) public{
        if(UM.user_IsExist(account)) {
            stock[account][stockId] = stockTxn(stock_Name, stock_NowPrice, stock_Number, block.timestamp); 
        }
    }

    function get_User_StockId(string memory account, string memory stockId) public view returns(string memory, string memory, int, int, uint){
        stockTxn memory t = stock[account][stockId]; //txn mapping
        return (t.stock_Name, stockId, t.stock_NowPrice, t.stock_Number, t.stock_calltime);
    }
    
    //處理交易資料
    function trade_buy_Stock(string memory account, string memory stockId, string memory stock_Name, int stock_NowPrice, int stock_Number) public{
        bytes32 buy_bytes_stockId;
        assembly {
            buy_bytes_stockId := mload(add(stockId, 32))
        }
        if(UM.user_IsExist(account)) {
            //stock[account][stockId].stock_Name = stockTxn(stock_Name, stock_NowPrice, stock_Number); 
            stock[account][stockId].stock_Name = stock_Name; 
            stock[account][stockId].stock_NowPrice = stock_NowPrice;
            stock[account][stockId].stock_Number = stock[account][stockId].stock_Number + stock_Number;
            stock[account][stockId].stock_calltime = block.timestamp;
            int expenseStock = stock_NowPrice * stock_Number;       //數量*價格 = 花費金額(傳入)
            (int cash, int value) = UM.get_UserMoney(account);             //拿到UserManage的cash跟value
            if(cash >= expenseStock){                       //判斷是否有錢買股票
                cash = cash - expenseStock;                 //買股票後金額
                value = value + expenseStock;               //買股票後股票價值
                UM.update_UserMoney(account, cash, value);   //回傳金額
            }
            //是否已有別人購買此股票
            bool stock_state = true;
            for(uint i = 0 ; i < buy_allStockId.length ; i++) {
                if(buy_allStockId[i] == buy_bytes_stockId){
                    stock_state = false;
                }
            }
            if(stock_state == true){
                buy_allStockId.push(buy_bytes_stockId);
            }
            //儲存購買的股票進入該帳號
            buy_allStockData[account].push(buy_bytes_stockId);
        }
    }
    
    // +取得需要購買股票陣列FUNCTION
    //目前所有有被購買的股票可用此FUNCTION查詢
    function get_Txn_allStockId() public view returns(bytes32[] memory){
        return buy_allStockId;
    }
    
    // +取得個人購買股票陣列FUNCTION
    //查詢個人有購買的股票可用此FUNCTION查詢
    function get_Txn_userStockId(string memory account) public view returns(bytes32[] memory){
        return buy_allStockData[account];
    }
    
    //觀看使用者已購買股票
    // function hold_UserStock(string memory account) public view returns(bytes32[] memory){
    //     buy_allStockData[account] = stockTxn(stock_NowPrice, stock_Number);
    //     return buy_allStockId;
    // }
    
    //更新使用者股票價值
    function update_UserStockvalue(string memory account, string memory stockId, int stock_NowPrice) public{
        if(UM.user_IsExist(account)){
            //stock[account][stockId] = stockTxn(stock_Name, stock_NowPrice, stock_Number); 
            stock[account][stockId].stock_NowPrice = stock_NowPrice;
            //uint update_expenseStock = stock_NowPrice * stock_Number;
            // (uint value) = UM.get_UserStockValue(account);
            //stock[account][stockId].stock_NowPrice =  update_expenseStock;
            //UM.update_UserStockValue(account, stock[account][stockId].stock_NowPrice);
        }
    }
    
    //使用者有哪些股票並進行計算股票價值
    function update_Txn_UserStockvalue(string memory account) public {
        int update_stockvalue = 0;
        int update_price;              
        int update_number;             
        if(UM.user_IsExist(account)){
            bytes32 []memory buyallStockData = buy_allStockData[account];
            for(uint i=0 ; i < buyallStockData.length ; i++){
                bytes32 temp = buyallStockData[i];
                string memory convertUserStockvalue;
                uint8 j = 0;
                while(j < 32 && temp[j] != 0) {
                    j++;
                }
                bytes memory bytesArray = new bytes(j);
                for (j = 0; j < 32 && temp[j] != 0; j++) {
                    bytesArray[j] = temp[j];
                }
                convertUserStockvalue = string(bytesArray);
                update_price = stock[account][convertUserStockvalue].stock_NowPrice;
                update_number = stock[account][convertUserStockvalue].stock_Number;
                update_stockvalue = update_stockvalue + update_price * update_number * 1000;
            }
            UM.update_UserStockValue(account, update_stockvalue);
            UM.update_UserRateOfReturn(account);
        }
    }
    uint test = 0;
    //賣出股票
    function trade_sell_UserStock(string memory account, string memory stockId, int stock_Number) public{
        bytes32 sell_bytes_stockId;
        assembly {
            sell_bytes_stockId := mload(add(stockId, 32))
        }
        
        if(UM.user_IsExist(account)){
            if(stock[account][stockId].stock_Number >= stock_Number)  {
                int earnStock = stock[account][stockId].stock_NowPrice * stock_Number;
                stock[account][stockId].stock_Number = stock[account][stockId].stock_Number - stock_Number;
                (int cash, int value) = UM.get_UserMoney(account); 
                cash = cash + earnStock;                    //賣股票後金額
                value = value - earnStock;                  //賣股票後股票價值
                UM.update_UserMoney(account, cash, value);   //回傳金額
                
                bytes32 []memory buyallStockData = buy_allStockData[account];
                for(uint i=0 ; i < buyallStockData.length ; i++){
                    bytes32 temp = buyallStockData[i];
                    if(temp == sell_bytes_stockId){
                        delete buy_allStockData[account][i];
                        test = test+3;
                    //儲存購買的股票進入該帳號
                    //buy_allStockData[account].pop(sell_bytes_stockId);
                    }
                }
            }  
        }
    }

    function gettest() public view returns(uint){
        return test;
    }
    
    uint[] arraytest = [1,2,3,4,5,6];
    function deletetest() public{
        delete arraytest[3];
    }
    function arraytest1() public view returns(uint[] memory){
        return arraytest;
    }
}