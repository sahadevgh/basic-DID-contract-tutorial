// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Contract to manage decentralized identity registration and verification
contract IdentityContract {

    // Address of the contract manager
    address public contractManager;

    // Struct to represent an identity
    struct Identity {
        address owner;             
        string email;               
        string first_name;          
        string last_name;           
        string verificationDoc;     
        bool isVerified;            
        bool isRevoke;              
    }

    // Array to store all registered identities
    Identity[] private allIdentities;

    // Mapping to check if an address is a verifier
    mapping (address => bool) public verifiers;

    // Mapping to store the identity associated with each address
    mapping (address => Identity) public userIdentity;

    // Constructor to initialize the contract manager and set them as the first verifier
    constructor(){
        contractManager = msg.sender;         // Assign the deployer as the contract manager
        verifiers[contractManager] = true;   // Add the manager to the list of verifiers
    }

    // Function to register a new identity
    function registerIdentity(
        string memory _email,
        string memory _first_name,
        string memory _last_name,
        string memory _verificationDoc
    ) public returns (Identity memory) {
        // Create a new identity struct
        Identity memory newIdentity = Identity({
            owner: msg.sender,
            email: _email,
            first_name: _first_name,
            last_name: _last_name,
            verificationDoc: _verificationDoc,
            isVerified: false,
            isRevoke: false
        });

        // Assign the new identity to the owner's address
        userIdentity[msg.sender] = newIdentity;

        // Add the identity to the list of all identities
        allIdentities.push(newIdentity);

        return newIdentity;
    }

    // Modifier to restrict access to only the contract manager
    modifier onlyManager(){
        require(msg.sender == contractManager, "You are not the contract manager");
        _;
    }

    // Function to add a verifier, restricted to the contract manager
    function addVerifier(address _verifier) public onlyManager {
        verifiers[_verifier] = true;
    }

    // Modifier to restrict access to verifiers only
    modifier onlyVerifier() {
        require(verifiers[msg.sender], "You are not a verifier");
        _;
    }

    // Function to verify an identity, restricted to verifiers
    function verifyIdentity(address _address) public onlyVerifier {
        userIdentity[_address].isVerified = true; // Mark the identity as verified
    }

    // Function to revoke an identity, restricted to verifiers
    function revokeIdentity(address _address) public onlyVerifier {
        userIdentity[_address].isVerified = false; // Mark the identity as not verified
        userIdentity[_address].isRevoke = true;    // Mark the identity as revoked
    }

    // Function to remove a verifier, restricted to verifiers
    function removeVerifier(address _address) public onlyVerifier {
        verifiers[_address] = false; // Remove the address from the list of verifiers
    }

    // Function to get all registered identities, restricted to verifiers
    function getAllRegistrations() public view onlyVerifier returns (Identity[] memory) {
        return allIdentities; // Return the list of all identities
    }
}
