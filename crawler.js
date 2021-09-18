import axios from 'axios';

const request = require('request') //axios
const cheerio = require('cheerio')

// 股票URL
let stockarray = [];
const searchId = async (id) => {
  const url = `https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_${id}.tw&json=1`;
  // 取得網頁資料
  const result = new Promise((resolve, reject) => {
    request(url, function (error, response, body) {
      const data = JSON.parse(body)
      // console.log("當前價格: " + data.msgArray[0].z);
      // console.log("最高價: " + data.msgArray[0].h);
      // console.log("最低價: " + data.msgArray[0].l);
      stockarray = [data.msgArray[0].n, data.msgArray[0].c, data.msgArray[0].z, data.msgArray[0].o, data.msgArray[0].h, data.msgArray[0].l];
      //stockarray = data;
      return resolve(stockarray);
    });
  });
  return result;
}
export default searchId;