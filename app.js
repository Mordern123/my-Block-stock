import express from "express";
import logger from "morgan";
import { connect_to_web3 } from "./function/web3";
import { getContractInstance, contract_call, contract_send } from "./function/contract";
import StockManagement from "./build/contracts/StockManagement.json";
import UserManagement from "./build/contracts/UserManagement.json";
import path from "./path.json";
import searchId from "./crawler.js";
import UserData from "./models/UserModel.js";
import StockData from "./models/StockModel.js";
import mongoose from "mongoose";
import cors from "cors";

require("dotenv").config(); //環境變數 
const app = express();  //建立一個express伺服器
app.use(express.json()); //回應能使用json格式
app.use(logger("dev")); //顯示呼叫的api在console畫面
app.use(cors());
app.use('/stock', express.static(__dirname + '/client/html'));

mongoose.connect('mongodb://localhost:27017/my-block-stock');
const connection = mongoose.connection;
connection.on('error', console.error.bind(console, 'connection error:'));
connection.once("open", () => {
    console.log('------------------------------------------------------');
    console.log("MongoDB database connection established successfully");
    console.log("The database is " + connection.name);

});

const UM_Addr = path.UserManagementaddraddr;
const SM_Addr = path.StockManagementaddr;

let userid='';
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
    const userDB = await UserData({ //寫入UserData資料庫
        user_id: id,
        user_name: user_name,
        user_password: password,
        user_grade: user_grade,
        user_major: user_major,
    }).save();
}
//得到使用者資訊
const getUser = async (req, res) => {
    const { id, password } = req.query
    userid = id;
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, UserManagement.abi, UM_Addr);
    const get_user = await contract_call(contract, 'get_User', [id, password], {
        from: accounts[0],
        gas: 6000000,
    })
    res.json(get_user);
    console.log(userid);
    console.log("success call loginApi");
}
//得到使用者購買股票
const tradeBuy = async (req, res) => {
    const { stockid, stock_name, stock_price, stock_number } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, StockManagement.abi, SM_Addr);
    const trade_buy_stock = await contract_send(contract, 'trade_buy_Stock', [userid, stockid, stock_name, stock_price, stock_number], {
        from: accounts[0],
        gas: 6000000,
    })
    res.json(trade_buy_stock);
    const stockDB = await StockData({ //寫入UserData資料庫
        user_id: userid,
        stockid: stockid,
        stock_name: stock_name,
        stock_price: stock_price,
        stock_number: stock_number,
    }).save();
}

const getStock = async (req, res) => {
    const { stockid } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, StockManagement.abi, SM_Addr);
    const get_User_StockId = await contract_call(contract, 'get_User_StockId', [userid, stockid], {
        from: accounts[0],
        gas: 6000000,
    })
    res.json(get_User_StockId);
}

const tradeSell = async (req, res) => {
    const { stockid, stock_number } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, StockManagement.abi, SM_Addr);
    const trade_sell_UserStock = await contract_send(contract, 'trade_sell_UserStock', [userid, stockid, stock_number], {
        from: accounts[0],
        gas: 6000000,
    })
    res.json(trade_sell_UserStock);
    // const stockDB = await StockData({ //寫入UserData資料庫
    //     user_id: userid,
    //     stockid: stockid,
    //     stock_name: stock_name,
    //     stock_price: stock_price,
    //     stock_number: stock_number,
    // }).save();
}

const getMoney = async (req, res) => {
    const { } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, UserManagement.abi, UM_Addr);
    const getmoney = await contract_call(contract, 'getMoney', [userid], {
        from: accounts[0],
        gas: 6000000,
    })
    res.json(getmoney);
}

const updateUserMoney = async (req, res) => {
    const { } = req.query
    const web3 = await connect_to_web3();
    const accounts = await web3.eth.getAccounts();
    const contract = await getContractInstance(web3, StockManagement.abi, SM_Addr);
    const update_userMoney = await contract_send(contract, 'update_UserMoney', [userid, cash, stockvalue], {
        from: accounts[0],
        gas: 6000000,
    })
    res.json(update_userMoney);
}

const stock = async (req, res) => {
    const { id } = req.query
    const stockid = await searchId(id);
    console.log(stockid);
    res.json(stockid);
}
// stock();getMoney\tradeSellgetStock
app.get('/getMoney', getMoney);
app.post('/updateUserMoney', updateUserMoney);
app.post('/stock', stock);
app.post('/create', create);
app.get('/getUser', getUser);
app.post('/tradeBuy', tradeBuy);
app.get('/getStock', getStock);
app.post('/tradeSell', tradeSell);
app.listen(process.env.LISTENING_PORT, () => {
    console.log(`App listening at http://localhost:${process.env.LISTENING_PORT}`);
});
