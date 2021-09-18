import axios from "axios";

export const test_serverAddress = "localhost:5000";
export const baseURL = `http://${test_serverAddress}`;
const request = axios.create({ baseURL: `${baseURL}`, withCredentials: true });

export const apiCreate = (data) => request.post("/create",data);//創建帳號

export const apiStockInfo = (data) => request.post("/stock",data);//查詢股票