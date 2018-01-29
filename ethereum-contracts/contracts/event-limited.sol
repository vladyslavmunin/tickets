pragma solidity ^0.4.17;

contract LimitedEvent {

        
    /*
         issue Tickets as tokens 
         limited count of tickets e.g. 300
         each address in mapping  - real address.
         
    */
    uint public total;
    string public eventName;
    address public eventOwner; 
    mapping(address => uint256) public visitors;
    uint256 public eventTime;
 

    /*
        - soldTickets : count of tickets which were sold
        - usedTickets : count of tickets which were scanned
    */

    uint public soldTickets; 
    uint public usedTickets;
    /*
       restrictions 
    */
    uint256 ticketsPerAddress = 10;

    function LimitedEvent(string _name,uint _ticketsCount,uint256 _eventTime) public {
        eventName = _name;
        total = _ticketsCount;
        eventTime = _eventTime;
        eventOwner = msg.sender;
    }
      /*
        modifiers 
        - onlyEventOwner : function can called only by event owner account
        - soldOut        : no more than total tickets count
        - personLimit    : no more than ticket restriction per address
        - notStarted     : event didn't started yet
      */
       modifier onlyEventOwner(){
           require(eventOwner == msg.sender);
           _;
       }
       modifier soldOut(uint count) {
           require(soldTickets + count <= total);
           _;
       }
       modifier personLimit(uint count,address visitor) {
           require(visitors[visitor] + count <= ticketsPerAddress);
           _;
       }
       modifier notStarted(){
           require(now < eventTime);
           _;
       }
       modifier started(){
             require(now >= eventTime);
           _;
       }
       /*

         -- can address own more then one tickets  -> yes 
         so ... maybe - mapping address -> uint ? where uint 0 - 8 

         --but ticket 

         1) check that number of solded tickets 
         2) update value in mapping e.g visitors[address].ticktes += param;
         3) increase count of solded tickets
       */
       function buy(address _address,uint _ticketsCount ) 
           public
           onlyEventOwner              // ? if payment isn't needed directly in contract -> transaction from event owner
           soldOut(_ticketsCount)
           personLimit(_ticketsCount,_address)
           notStarted

           returns (bool success)
       {
           visitors[_address] += _ticketsCount;
           soldTickets += _ticketsCount;
           success = true;
       }

 
       /*
        -- sell ticketv (exchange)

        -- does ticket have a number? - no.

        1) check that _from has needed tickets  count
        2) decrease number of _from tickets
        3) increase number of _to tickets
        4) emit Tranfser Event

  */
        function sell(address _address,uint _ticketsCount ) 
           public
           personLimit(_ticketsCount,_address)
           notStarted
           returns (bool success)
       {
           require(visitors[msg.sender] > _ticketsCount);
           visitors[msg.sender] -= _ticketsCount;
           visitors[_address] += _ticketsCount;
           success = true;
       }
  /*

        -- scan Ticket 

        1) check that _from (msg.sender) has needed tickets  
        2) check that  buying ticket is closeds 
        3) decrease number of _from tickets
        4) increase number of used tickets
        5) emit scan event
    */
    function scan(address _address ) 
           public
           onlyEventOwner
           started     
           returns (bool success)
       {
           require(visitors[_address] >= 1);

           visitors[_address] -= 1;
           usedTickets += 1;
           success = true;
       }
    
}

