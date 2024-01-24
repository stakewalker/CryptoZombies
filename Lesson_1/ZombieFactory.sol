// Specifies the compatible Solidity compiler versions for this contract
pragma solidity >=0.5.0 <0.6.0;

// Contract definition for 'ZombieFactory'
contract ZombieFactory {

    // Event declaration - used for logging the creation of new zombies
    event NewZombie(uint zombieId, string name, uint dna);

    // Constant that represents the number of digits in a zombie's DNA
    uint dnaDigits = 16;
    // A modulus to ensure a zombie's DNA has exactly `dnaDigits` digits
    uint dnaModulus = 10 ** dnaDigits;

    // Definition of the 'Zombie' struct with 'name' and 'dna' attributes
    struct Zombie {
        string name;
        uint dna;
    }

    // Array to store all the zombies
    Zombie[] public zombies;

    // Internal function to create a new zombie and add it to 'zombies' array
    function _createZombie(string memory _name, uint _dna) private {
        // Adding the new Zombie to the array and getting the new Zombie's ID
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // Emitting an event to log the zombie creation
        emit NewZombie(id, _name, _dna);
    }

    // Private function to generate a random DNA based on an input string
    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Generating a pseudo-random number using keccak256 hash function
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        // Ensuring the DNA has the correct number of digits
        return rand % dnaModulus;
    }

    // Public function that allows creating a zombie with a random DNA, based on its the name
    function createRandomZombie(string memory _name) public {
        // Generating a random DNA
        uint randDna = _generateRandomDna(_name);
        // Creating a new zombie with the generated DNA and provided name
        _createZombie(_name, randDna);
    }

}
