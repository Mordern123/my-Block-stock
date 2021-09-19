import  mongoose  from "mongoose";
const Schema = mongoose.Schema;

const StockDataSchema = new Schema({
    user_id:{
        type: String,
        required: true,
        trim: true,
    },
    stockid:{
        type: String,
        required: true,
        trim: true,
    },
    stock_name:{
        type: String,
        required: true,
        trim: true,
    },
    stock_price:{
        type: Number,
        required: true,
        trim: true,
    },
    stock_number:{
        type: Number,
        required: true,
        trim: true,
    },
})

const StockData = mongoose.model("StockData", StockDataSchema, 'Stock_Data');

export default StockData;
