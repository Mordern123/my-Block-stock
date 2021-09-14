import express from "express";
import logger from "morgan";
import { connect_to_web3 } from "./function/web3";
import { getContractInstance, contract_call, contract_send } from "./function/contract"; 
import StockManagement from "./build/contracts/StockManagement.json";
import UserManagement from "./build/contracts/UserManagement.json";
import path from "./path.json";
import searchId from "./crawler.js";

require("dotenv").config(); //環境變數 
const app = express();  //建立一個express伺服器
app.use(express.json()); //回應能使用json格式
app.use(logger("dev")); //顯示呼叫的api在console畫面

const UM_Addr = path.UserManagementaddraddr;
const SM_Addr = path.StockManagementaddr;

//創建使用者
const create = async (req, res) => {
    const { id, user_name, password, user_grade, user_major } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, UserManagement.abi, UM_Addr);
        const set_user = await contract_send(contract, 'setUser', [id, user_name, password, user_grade, user_major], {
            from: accounts[0],
            gas: 6000000,
        })
        res.json(set_user);
}
//得到使用者資訊
const getUser = async (req, res) => {
    const { id } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, UserManagement.abi, UM_Addr);
        const get_user = await contract_call(contract, 'get_User', [id], {
            from: accounts[0],
            gas: 6000000,
        })
        res.json(get_user);
}
//得到使用者購買股票
const tradeBuy = async (req, res) => {
    const { id, stockid, stock_name, stock_price, stock_number } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, StockManagement.abi, SM_Addr);
        const trade_buy_stock = await contract_send(contract, 'trade_buy_Stock', [id, stockid, stock_name, stock_price, stock_number], {
            from: accounts[0],
            gas: 6000000,
        })
        res.json(trade_buy_stock);
}

// const id=1234;
// const stock = async() => {
//     const stockid = await searchId(id);
//     console.log(stockid);
// }
const stock = async (req, res) => {
    const { id } = req.query
    const stockid = await searchId(id);
    res.json(stockid);
}
// stock();
app.post('/stock', stock);
app.post('/create', create);
app.get('/getUser', getUser);
app.post('/create/tradeBuy', tradeBuy);
app.listen(process.env.LISTENING_PORT, () => {
	console.log(`App listening at http://localhost:${process.env.LISTENING_PORT}`);
});
