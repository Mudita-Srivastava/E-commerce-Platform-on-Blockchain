// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {

    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }
    mapping(uint256 => Item) public items;
    //no of order of one person
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    constructor() {
        owner=msg.sender;
    }
    event List(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer, uint256 orderId, uint256 itemId);

modifier onlyOwner(){
    require(msg.sender == owner);
    _;
}
    //list products
    function list(
        uint256 _id,
         string memory _name,
          string memory _category,
          string memory _image,
          uint256 _cost,
          uint256 _rating,
          uint256 _stock
          ) public onlyOwner{

            
         //cretae Item struct
         Item memory item = Item(
            _id, 
            _name,
             _category, 
             _image, 
             _cost, 
             _rating,
              _stock
              );
         //save Item struct to blockchain
         items[_id]= item;
         //emit an event
         emit List(_name, _cost, _stock);
    }

    //buy products
function buy(uint256 _id) public payable{
    //receive crypto
    //fetch item
    Item memory item = items[_id];
    //rnough ether to buy items
    require(msg.value >= item.cost);
    require(item.stock>0);

    //create an order
    Order memory order = Order(block.timestamp, item);
    //save order to chain
orderCount[msg.sender]++; //orderid
orders[msg.sender][orderCount[msg.sender]]= order;

    //substract stock
    items[_id].stock= item.stock-1;

    //emit event
    emit Buy(msg.sender, orderCount[msg.sender], item.id);
}

    //withdraw funds from person who owns the market place
function withdraw() public onlyOwner{
    (bool success,)= owner.call{value: address(this).balance}("");
    //It sends the entire balance (address(this).balance) of the current contract to the owner address.
    require(success);
}
}
