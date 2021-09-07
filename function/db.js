import mongoose from "mongoose";
import ItemModel from "../models/itemModel";

export const connect_to_mongodb = () => {
	const connection = mongoose.connection;

	//註冊連結資料事件
	connection.once("open", () => {
		console.log("MongoDB database connection established successfully");
		console.log("The database is " + connection.name);
	});

	//連結資料庫
	mongoose.connect(process.env.MONGODB_CONNECT_STRING, {
		useNewUrlParser: true,
		useCreateIndex: true,
		useUnifiedTopology: true,
	});

	//設定更新後回傳最新資料
	mongoose.set("useFindAndModify", false);
};

export const add_item_to_mongodb = async (key, value) => {
	const newItem = await new ItemModel({
		key,
		value,
	}).save();

	return newItem.toJSON();
};

export const update_item_from_mongodb = async (key, value) => {
	const result = await ItemModel.updateOne({ key }, { value }).exec();
	return result;
};

export const delete_item_from_mongodb = async (key) => {
	const result = await ItemModel.deleteOne({ key }).exec();
	return result.ok;
};
