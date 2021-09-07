const request = require('request') //axios
const cheerio = require('cheerio')

// 股票URL
const url = "https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_1444.tw&json=1&delay=2&_=1607865290111";

// 取得網頁資料
request(url, function (error, response, body) {
  const data = JSON.parse(body)
  //console.log(data);
  
  console.log("股票名稱: "+ data.msgArray[0].n);
  console.log("股票代號: "+ data.msgArray[0].c);
  console.log("開盤價: "+ data.msgArray[0].o);
  console.log("當前價格: "+ data.msgArray[0].z);
  console.log("最高價: "+ data.msgArray[0].h);
  console.log("最低價: "+ data.msgArray[0].l);
   if (!error) {

     // 用 cheerio 解析 html 資料
     //const $ = cheerio.load(data);
     
    //const list = $(msgArray[0]["n"]);

    // 篩選有興趣的資料
    //const title = $('tv').text();  

    // 輸出
     //coneole.log(data.msgArray[2]);

  } else {
    console.log("擷取錯誤：" + error);
  }
});

