// SPDX-License-Identifier: MIT
// pragma directive specifying the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the Ownable contract
import "./Ownable.sol";
// Importing the SafeMath library for safe arithmetic operations
import "./SafeMath.sol";

// ZombieFactory contract, inheriting from Ownable
contract ZombieFactory is Ownable {

    // Using SafeMath library to prevent overflows and underflows in uint256
    using SafeMath for uint256;
    // Using SafeMath32 library to prevent overflows and underflows in uint32
    using SafeMath32 for uint32;
    // Using SafeMath16 library to prevent overflows and underflows in uint16
    using SafeMath16 for uint16;

    // Event emitted when a new zombie is created
    event NewZombie(uint zombieId, string name, uint dna);

    // Number of digits in the DNA sequence
    uint dnaDigits = 16;
    // Modulus used to limit the DNA sequence to a specific range
    uint dnaModulus = 10 ** dnaDigits;
    // Cooldown time before a zombie can be used again (1 day)
    uint cooldownTime = 1 days;

    // Struct representing a Zombie
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Array to store all zombies
    Zombie[] public zombies;

    // Mapping from zombie ID to owner address
    mapping (uint => address) public zombieToOwner;
    // Mapping from owner address to the number of zombies owned
    mapping (address => uint) ownerZombieCount;

    // Internal function to create a new zombie
    function _createZombie(string memory _name, uint _dna) internal {
        // Push a new Zombie struct into the zombies array
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        // Set the owner of the new zombie
        zombieToOwner[id] = msg.sender;
        // Increment the zombie count for the owner
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        // Emit the NewZombie event
        emit NewZombie(id, _name, _dna);
    }

    // Internal function to generate random DNA based on a string input
    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Generate a random number using keccak256 hash of the input string
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        // Return the random number within the DNA modulus range
        return rand % dnaModulus;
    }

    // Public function to create a random zombie with a given name
    function createRandomZombie(string memory _name) public {
        // Require that the owner has no existing zombies
        require(ownerZombieCount[msg.sender] == 0);
        // Generate random DNA based on the given name
        uint randDna = _generateRandomDna(_name);
        // Reduce the random DNA to a 2-digit number
        randDna = randDna - randDna % 100;
        // Create a new zombie with the random DNA and given name
        _createZombie(_name, randDna);
    }
}
