import  mongoose  from "mongoose";
const Schema = mongoose.Schema;

const UserDataSchema = new Schema({
    user_id:{
        type: String,
        required: true,
        trim: true,
    },
    user_name:{
        type: String,
        required: true,
        trim: true,
    },
    user_password:{
        type: String,
        required: true,
        trim: true,
    },
    user_grade:{
        type: String,
        required: true,
        trim: true,
    },
    user_major:{
        type: String,
        required: true,
        trim: true,
    },
})

const UserData = mongoose.model("UserData", UserDataSchema, 'User_Data');

export default UserData;
