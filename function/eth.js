// 取得區塊鏈上常用資訊
export const get_blockchain_info = async (web3) => {
	try {
		let accounts = await web3.eth.getAccounts(); //所有帳戶
		let is_mining = await web3.eth.isMining(); //是否正在挖礦
		let coinbase = await web3.eth.getCoinbase(); //挖礦獎勵帳戶
		let node_info = await web3.eth.getNodeInfo(); //節點資訊
		let gas_price = await web3.eth.getGasPrice(); //燃料
		let block_number = await web3.eth.getBlockNumber(); //目前區塊編號
		let network_id = await web3.eth.net.getId(); //網路id
		let is_listening = await web3.eth.net.isListening(); //是否正在監聽
		let peer_count = await web3.eth.net.getPeerCount(); //節點數量
		let default_account = web3.eth.defaultAccount; //預設操作帳戶
		let default_chain = web3.eth.defaultChain; //網路類型

		return {
			accounts,
			is_mining,
			coinbase,
			node_info,
			gas_price,
			block_number,
			network_id,
			is_listening,
			peer_count,
			default_account,
			default_chain,
		};
	} catch (error) {
		console.log(error);
		return null;
	}
};
