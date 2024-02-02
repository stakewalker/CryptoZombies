// Specifies the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the Ownable contract
import "./Ownable.sol";

// ZombieFactory contract, inheriting from Ownable
contract ZombieFactory is Ownable {

    // Event emitted when a new zombie is created
    event NewZombie(uint zombieId, string name, uint dna);

    // Constant for DNA digits
    uint dnaDigits = 16;
    // Modulus for trimming the DNA to 16 digits
    uint dnaModulus = 10 ** dnaDigits;
    // Cooldown time for actions
    uint cooldownTime = 1 days;

    // Struct to define a Zombie
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    // Dynamic array to store Zombies
    Zombie[] public zombies;

    // Mapping from zombie ID to owner address
    mapping (uint => address) public zombieToOwner;
    // Mapping from owner address to their zombie count
    mapping (address => uint) ownerZombieCount;

    // Internal function to create a zombie
    function _createZombie(string memory _name, uint _dna) internal {
        // Adding a new Zombie to the array and getting its ID
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;
        // Assigning the zombie to the caller
        zombieToOwner[id] = msg.sender;
        // Incrementing the owner's zombie count
        ownerZombieCount[msg.sender]++;
        // Emitting the NewZombie event
        emit NewZombie(id, _name, _dna);
    }

    // Private function to generate a random DNA
    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Generating a pseudo-random number
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        // Trimming the random number to DNA digits
        return rand % dnaModulus;
    }

    // Public function to create a random zombie
    function createRandomZombie(string memory _name) public {
        // Ensuring this is the first zombie for the owner
        require(ownerZombieCount[msg.sender] == 0);
        // Generating a random DNA
        uint randDna = _generateRandomDna(_name);
        // Ensuring the last two digits of DNA are 0
        randDna = randDna - randDna % 100;
        // Creating a new zombie with the generated DNA
        _createZombie(_name, randDna);
    }

}
