pragma solidity ^0.4.24;
import "./Chore.sol";
contract Scheduler{
    mapping(address => uint[]) weeklyassignments; //housemates to chores
    mapping(uint => Chore) choreLookup; //identify chore from number id
    mapping(address => HouseMate) housemateLookup; //identify housemate from string id
    address[] housemates;
    uint[]chores;
    Chore currentEvent;
    uint majority;

    struct HouseMate{
        string id;
        string pub_name;
        uint points;
    }

    constructor(uint[] c, address[] h) public {
        chores = c;
        housemates = h;
        majority = housemates.length / 2;
        assignChores(chores);

    }

    function assignChores(uint[] c) private {
        uint choresPerPerson = c.length / housemates.length;
        for(uint hM = 0; hM < housemates.length; hM++){
            uint[] memory choreList;
            uint start = hM * choresPerPerson;
            uint end = start + choresPerPerson;
            //case of number of chores and number of housemates not in perfect alignment
            if(hM == housemates.length -1){
                end = c.length-1;
            }
            for(uint i = start; i < end; i++){
                choreList[i] = c[i];
            }
            weeklyassignments[housemates[hM]] = choreList;
        }
    }

    function identifyHouseMate(address h) public returns(string){
        return housemateLookup[h].pub_name;
    }

    function identifyChore(uint c) public returns(string){
        return choreLookup[c].getDesc();
    }

    function shuffle() public{
        address prev = housemates[0];
        for(uint i = 1; i < housemates.length; i++){
            address temp = housemates[i];
            housemates[i] = prev;
            prev = temp;
        }
        housemates[0] = prev;
        assignChores(chores);
    }


}
