//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "./VoteLib.sol";

contract Voting {
    using VoteLib for VoteLib.Candidate[];

    struct Voter {
        bool hasVoted;
        uint256 votedFor;
    }

    mapping(address => Voter) public voters;
    VoteLib.Candidate[] public candidates;

    address public admin;
    bool public votingOpen;

    event VoteCasted(address indexed voter, uint256 indexed candidateIndex);
    event VotingStarted();
    event VotingEnded();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    modifier votingActive() {
        require(votingOpen, "Voting is not active");
        _;
    }

    constructor(string[] memory candidateNames) {
        admin = msg.sender;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(VoteLib.Candidate({name: candidateNames[i], votes: 0}));
        }
    }

    
    function startVoting() public onlyAdmin {
        require(!votingOpen, "Voting already active");
        votingOpen = true;
        emit VotingStarted();
    }

    
    function endVoting() public onlyAdmin {
        require(votingOpen, "Voting is not active");
        votingOpen = false;
        emit VotingEnded();
    }

    
    function castVote(uint256 candidateIndex) public votingActive {
        require(!voters[msg.sender].hasVoted, "Already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");

        voters[msg.sender] = Voter({hasVoted: true, votedFor: candidateIndex});
        candidates[candidateIndex].castVote();

        emit VoteCasted(msg.sender, candidateIndex);
    }

    
    function determineWinner() public view returns (string memory winner, uint256 voteCount) {
        require(!votingOpen, "Voting is still active");
        return candidates.getWinner();
    }

    
    function getCandidates() public view returns (VoteLib.Candidate[] memory) {
        return candidates;
    }
}