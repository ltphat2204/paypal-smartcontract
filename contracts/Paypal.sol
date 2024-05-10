// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Paypal {
	address public owner;

	constructor() {
		owner = msg.sender;
	}

	struct Request {
		address requestor;
		uint256 amount;
		string message;
		string name;
	}

	struct SendReceive {
		string action;
		uint256 amount;
		string message;
		address otherPartyAddress;
		string otherPartyName;
	}

	struct UserName {
		string name;
		bool hasName;
	}

	mapping(address => UserName) names;
	string constant NO_NAME = "Anonymous User";

	function getName(address _user) public view returns (string memory) {
		if (names[_user].hasName) {
			return names[_user].name;
		}
		return NO_NAME;
	}

	mapping(address => Request[]) requests;
	mapping(address => SendReceive[]) history;

	function addName(string memory _name) public {
		UserName storage newUserName = names[msg.sender];
		newUserName.name = _name;
		newUserName.hasName = true;
	}

	function createRequest(address user, uint256 _amount, string memory _message) public {
		Request memory newRequest;
		newRequest.requestor = msg.sender;
		newRequest.amount = _amount;
		newRequest.message = _message;
		newRequest.name = getName(msg.sender);
		requests[user].push(newRequest);
	}

	function payRequest(uint256 _request) public payable {
		require(_request < requests[msg.sender].length, "Invalid Request");
		Request[] storage myRequests = requests[msg.sender];
		Request storage payableRequest = myRequests[_request];

		uint256 toPay = payableRequest.amount * 10**18;
		require(msg.value == toPay, "Incorrect amount");

		payable(payableRequest.requestor).transfer(msg.value);
		addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);

		myRequests[_request] = myRequests[myRequests.length - 1];
		myRequests.pop();
	}

	function makeHistory(string memory action, address to, uint256 _amount, string memory _message) private view returns (SendReceive memory) {
		SendReceive memory newHistory;
		newHistory.action = action;
		newHistory.amount = _amount;
		newHistory.message = _message;
		newHistory.otherPartyAddress = to;
		newHistory.otherPartyName = getName(to);
		return newHistory;
	}

	function addHistory(address sender, address receiver, uint256 _amount, string memory _message) private {
		SendReceive memory newSend = makeHistory("-", receiver, _amount, _message);
		history[sender].push(newSend);

		SendReceive memory newReceive = makeHistory("+", sender, _amount, _message);
		history[receiver].push(newReceive);
	}

	function getMyRequests(address _user) public view returns (
		address[] memory,
		uint256[] memory,
		string[] memory,
		string[] memory
	) {
		address[] memory addrs = new address[](requests[_user].length);
		uint256[] memory amt = new uint256[](requests[_user].length);
		string[] memory msge = new string[](requests[_user].length);
		string[] memory nme = new string[](requests[_user].length);

		for (uint256 i = 0; i < requests[_user].length; i++) {
			Request storage myRequests = requests[_user][i];
			addrs[i] = myRequests.requestor;
			amt[i] = myRequests.amount;
			msge[i] = myRequests.message;
			nme[i] = myRequests.name;
		}

		return (addrs, amt, msge, nme);
	}

	function getMyHistory(address _user) public view returns (SendReceive[] memory) {
		return history[_user];
	}
}
