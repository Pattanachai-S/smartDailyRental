pragma solidity ^0.4.19;

import "./ownable.sol";

contract rental is Ownable{
    
    mapping (uint => address) roomToUser; // room number to user
    
    struct Room {
        uint number;  // room number
        uint useTime;  // used until
        address user;  // keep user addr
    }
    
    uint roundPeriod = 1 hours; // use time per round = 1hr
    uint prices = 0.01 ether; // about 3.5 $
    
    mapping (uint => Room) rooms;
    
    
    function rental () public{
        createRoom(101); // createRoom 
        createRoom(102);
        createRoom(103);
    }
    
    function setRoundPeriod(uint _time) public onlyOwner {
        // Change round period
        roundPeriod = _time; //  In seconds
    }
    
    function getRoundPeriod() external view returns(uint) {
        // get period time per round
        return roundPeriod;
    }
    
    function setPrice(uint _price) public onlyOwner {
        // Set new prices per round
        prices = _price;
    }
    
    function getPrice() external view returns(uint) {
        // Get current pricecs 
        return prices;
    }
    
    function createRoom(uint _number) public onlyOwner {
        // create new room
        rooms[_number] = Room(_number, now, msg.sender);
    }
    
    function rent (uint _number) external payable{
        Room cRoom = rooms[_number];
        // can rent when room is Availability or user as the person who is using it. 
        require(compareString(getRoomStatus(cRoom.number), "Availability") || (cRoom.user == msg.sender));
        require(msg.value == prices);  
        addUseTime(_number);
        cRoom.user = msg.sender;
        withdraw(); // Transfer ether to owner
    }
    
    function addUseTime(uint _number) internal {
        // Add usetime for using room
        Room cRoom = rooms[_number];
        if (cRoom.useTime > now){
            // if room in using
            cRoom.useTime = (cRoom.useTime + roundPeriod);
        }else{
            // if room Availability
            cRoom.useTime = (now + roundPeriod);
        }
    }
    
    
    function getRoomStatus (uint _number) public view returns(string){
        Room cRoom = rooms[_number];
        if (now > cRoom.useTime){
            return "Availability";
        }else{
            return "Unavailability";
        }
    }
    
    function getTimeLeft(uint _number) public view returns(uint){
        uint result = (rooms[_number].useTime - now);
        return result;
    }
    
    function compareString (string _str1, string _str2) private returns(bool){
        return keccak256(_str1) == keccak256(_str2);
    }
    
    function withdraw() public { 
        // Withdraw eher on this contract
		owner.transfer(this.balance); 
    }
    
}