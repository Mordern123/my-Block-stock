import Web3 from "web3";

//連結web3
export const connect_to_web3 = async () => {
	try {
		const provider = new Web3.providers.HttpProvider(process.env.WEB3_PROVIDER_URL);
		let web3 = new Web3(provider);
		return web3;
	} catch (error) {
		console.log(error);
		return null;
	}
};
