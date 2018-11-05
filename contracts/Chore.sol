pragma solidity ^0.4.24;
contract Chore {
    mapping(address => bool[]) signers; //maps housemate addresses to an array of 4 boolean values
    address[] addressList; //array of all housemate addresses
    address assignedPerson; //address of housemate tasked with completing this chore
    string choreDescription;
    uint reward; //points rewarded to assignedPerson for completing this chore
    uint numberOfAgreed; //counts number of people agreeing that this chore is valid
    bool enoughAgreed; //determines if numberOfAgreed is enough
    uint numberOfCancelers; //counts number of people wishing to cancel the chore after the chore was deemed valid

    constructor(address[] s, string description, uint r, address a) public {
        addressList = s;
        for(uint i = 0; i < s.length; i++) {
            signers[s[i]] = [false, false, false, false]; //[hasAgreed, wantsToCancel, hasVotedFor, hasVotedAgainst]
        }
        reward = r;
        assignedPerson = a;
        choreDescription = description;
        numberOfAgreed = 0;
        enoughAgreed = false;
        numberOfCancelers = 0;
    }

    function getDesc() public returns(string){
        return choreDescription;
    }

    //function lets the msg.sender agree the chore is valid and then counts their vote
    function agreeToCreateChore() public {
        require(signers[msg.sender][0] == false);

        signers[msg.sender][0] = true;
        numberOfAgreed += 1;
        //rechecks the numberOfAgreed in order to avoid race condition
        if (numberOfAgreed > addressList.length / 2) {
            uint numberOfAgreed2 = 0;
            for(uint i = 0; i < addressList.length; i++) {
                if (signers[addressList[i]][0]) {
                    numberOfAgreed2++;
                }
            }
            numberOfAgreed = numberOfAgreed2;
            if (numberOfAgreed2 > addressList.length / 2) {
                enoughAgreed = true;
            }
        }
    }

    //If enoughAgreed is false, this function takes back the user's chore validity vote
    //Otherwise, this function lets the user vote to cancel the chore's validity
    function cancelChoreCreation() public {
        require(signers[msg.sender][0] == true);
        require(signers[msg.sender][1] == false);

        if (enoughAgreed) {
            signers[msg.sender][1] = true;
            numberOfCancelers += 1;
            //rechecks the numberOfCancelers in order to avoid race condition
            if (numberOfCancelers > numberOfAgreed / 2) {
                uint numberOfCancelers2 = 0;
                for(uint i = 0; i < addressList.length; i++) {
                    if(signers[addressList[i]][1]) {
                        numberOfCancelers2++;
                    }
                }
                numberOfCancelers = numberOfCancelers2;
                if (numberOfCancelers2 > numberOfAgreed / 2) {
                    enoughAgreed = false;
                    numberOfAgreed = 0;
                    numberOfCancelers = 0;
                    for(uint j = 0; j < addressList.length; j++) {
                        signers[addressList[j]] = [false, false, false, false];
                    }
                }
            }
        }
        else {
            signers[msg.sender] = [false, false, false, false];
            //doesn't decrement numberOfAgreed in order to prevent users from decrementing it too many times
        }
    }

    //allows the user to vote if the assignedPerson has completed the chore or has not completed the chore
    function vote(bool against) public {
        require(enoughAgreed);
        require(signers[msg.sender][2] == false && signers[msg.sender][3] == false);

        if(against) {
            signers[msg.sender][3] = true;
        }
        else {
            signers[msg.sender][2] = true;
        }
    }

    //counts the number of people who voted the chore was completed and the number of people who voted it was not
    function countFinalVote() public view returns(uint, uint){
        require(enoughAgreed);

        uint forVoteCount = 0;
        uint againstVoteCount = 0;
        for(uint i = 0; i < addressList.length; i++) {
            if(signers[addressList[i]][2]) {
                forVoteCount += 1;
            }
            if(signers[addressList[i]][3]) {
                againstVoteCount += 1;
            }
        }
        return (forVoteCount, againstVoteCount);
    }
}
