// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24 ;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract DAO is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");

    struct PoliticalParty {
        string name; // BJP
        uint votes; // 100
    }

    struct Voting {
        mapping(string => PoliticalParty) politicalPartyAndVotes; // [BJP => 100,Congress => 200]
        string[] politicalPartiesList;
        uint votingPeriod;
        uint startTime;
    }
    uint256 public numberOfVotings = 0;
    mapping (uint256 => Voting) public votings; // (1 => Voting1, 2 => Voting2)

    uint256 constant MIN_VOTING_PERIOD = 7 days;
    
    constructor() {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addAdmin(address _admin) public onlyRole(ADMIN_ROLE){
        _grantRole(ADMIN_ROLE, _admin);
    }

    function addVoter(address _voter) public onlyRole(ADMIN_ROLE) {
        _grantRole(VOTER_ROLE, _voter);
    }

    function addParty(uint256 _votingId,string memory _partyName) public onlyRole(ADMIN_ROLE) {
        Voting storage voting = votings[_votingId];
        voting.politicalPartyAndVotes[_partyName] = PoliticalParty(_partyName, 0);
        voting.politicalPartiesList.push(_partyName);
    }

    function removeParty(uint256 _votingId, string memory _partyName) public onlyRole(ADMIN_ROLE) {
        Voting storage voting = votings[_votingId];
        delete voting.politicalPartyAndVotes[_partyName];

        for(uint i = 0; i < voting.politicalPartiesList.length; i++) {
            if(keccak256(abi.encodePacked(voting.politicalPartiesList[i])) == keccak256(abi.encodePacked(_partyName))) {
                delete voting.politicalPartiesList[i];
                break;
            }
        }
    }

    /**
     * @param _votingPeriod : The duration of the voting period in seconds
     * @return : The id of the voting
     */
    function createVoting(uint _votingPeriod) public onlyRole(ADMIN_ROLE) returns(uint256) {
        require(_votingPeriod >= MIN_VOTING_PERIOD, "The voting period should be more than 1 week");
        Voting storage newVoting = votings[numberOfVotings];
        newVoting.votingPeriod = _votingPeriod;
        newVoting.startTime = block.timestamp;

        numberOfVotings ++;
        return (numberOfVotings - 1);
    }
    
    function endVoting(uint256 _votingId) public view onlyRole(ADMIN_ROLE) returns(PoliticalParty memory){
        Voting storage voting = votings[_votingId];
        require(block.timestamp >= voting.startTime + voting.votingPeriod, "Voting is still in progress");

        PoliticalParty memory winner;
        winner.votes = 0;

        for (uint i = 0; i < voting.politicalPartiesList.length; i++) {
            string memory partyName = voting.politicalPartiesList[i];
            PoliticalParty storage party = voting.politicalPartyAndVotes[partyName];
            if (party.votes > winner.votes) {
                winner = party;
            }
        }

        return winner;
    }

    function vote(uint256 _votingId, string memory _partyName) public onlyRole(VOTER_ROLE) {        
        Voting storage voting = votings[_votingId];
        require(block.timestamp < voting.startTime + voting.votingPeriod, "Voting is over");
        
        PoliticalParty storage party = voting.politicalPartyAndVotes[_partyName];     
        if (keccak256(abi.encodePacked(party.name)) == "") {
            revert("The political party does not exist or has already been voted for");   
        }
        else
        { 
            party.votes++;
        } 
    }
}