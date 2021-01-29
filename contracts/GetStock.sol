// SPDX-License-Identifier: MIT
pragma solidity >=0.5.22 <0.9.0;
import "./UserManage.sol";

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
        string stock_Name;      //公司名稱
        uint stock_NowPrice;    //股票價格
        uint stock_Number;      //股票數量
    }
    // +所有股票價格mapping
    mapping(string => StockData) public allStockData;//股票代號去找股票資料
    struct StockData {
        string stock_Name;      //公司名稱
        uint stock_NowPrice;    //股票價格
    }
    
    // +所有股票id array(拿來看現在有哪些股票要搜尋)
    bytes32[] public allStockId;

    // +使用者搜尋股票FUNCTION(新增id array元素 + 篩選去除相同元素)
    function search_StockData(string memory stockId) public {
        bytes32 bytes_stockId;
        assembly {
            bytes_stockId := mload(add(stockId, 32))
        }
        
        bool stock_state = true;
        for(uint i = 0 ; i < allStockId.length ; i++) {
            if(allStockId[i] == bytes_stockId){
                stock_state = false;
            }
        }
        if(stock_state == true){
            allStockId.push(bytes_stockId);
        }
    }
    
    // +取得需要更新股票陣列FUNCTION
    function get_StockId() public view returns(bytes32[] memory){
        return allStockId;
    }
    
    // +更新所有股票值function(鏈下觸發)
    function update_StockData(string memory stockId, string memory stock_Name, uint stock_NowPrice) public{
        allStockData[stockId] = StockData(stock_Name, stock_NowPrice);
    }
    
    //目前mapping裡該股票的資訊
    function get_StockData(string memory stockId) public view returns(string memory, uint){
        StockData memory S = allStockData[stockId];
        return (S.stock_Name, S.stock_NowPrice);
    }

    //儲存股票資料
    function set_User_StockId(string memory account, string memory stockId, string memory stock_Name, uint stock_NowPrice, uint stock_Number) public{
        if(UM.user_IsExist(account)) {
            stock[account][stockId] = stockTxn(stock_Name, stock_NowPrice, stock_Number); 
        }
    }

    function get_User_StockId(string memory account, string memory stockId) public view returns(string memory, string memory, uint, uint){
        stockTxn memory t = stock[account][stockId]; //txn mapping
        return (t.stock_Name, stockId, t.stock_NowPrice, t.stock_Number);
    }
    
    //處理交易資料
    function trade_Stock(string memory account, string memory stockId, string memory stock_Name, uint stock_NowPrice, uint stock_Number) public{
        if(UM.user_IsExist(account)) {
            stock[account][stockId] = stockTxn(stock_Name, stock_NowPrice, stock_Number); 
            uint expenseStock = stock_NowPrice * stock_Number * 1000;       //數量*價格 = 花費金額(傳入)
            (uint cash, uint value) = UM.get_UserMoney(account);             //拿到UserManage的cash跟value
            if(cash >= expenseStock){                       //判斷是否有錢買股票
                cash = cash - expenseStock;                 //買股票後金額
                value = value + expenseStock;               //買股票後股票價值
                UM.update_UserMoney(account, cash, value);   //回傳金額
                
            }
            
        }
    }
}