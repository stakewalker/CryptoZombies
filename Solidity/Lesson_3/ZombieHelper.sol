// Specifies the Solidity version the contract is compatible with
pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieFeeding contract
import "./ZombieFeeding.sol";

// ZombieHelper contract extends ZombieFeeding
contract ZombieHelper is ZombieFeeding {

    // Modifier to check if a zombie's level is above a specified level
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;  // Continues execution of the modified function
    }

    // Function to change a zombie's name, only if it's above level 2
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
        // Checks if the caller is the owner of the zombie
        require(msg.sender == zombieToOwner[_zombieId]);
        // Updates the name of the specified zombie
        zombies[_zombieId].name = _newName;
    }

    // Function to change a zombie's DNA, only if it's above level 20
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
        // Checks if the caller is the owner of the zombie
        require(msg.sender == zombieToOwner[_zombieId]);
        // Updates the DNA of the specified zombie
        zombies[_zombieId].dna = _newDna;
    }

    // Function to retrieve all zombie IDs owned by a specific address
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        // Creates an array to hold the owner's zombie IDs
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        // Iterates over all zombies to find those owned by the specified address
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                // Adds the zombie's ID to the result array
                result[counter] = i;
                counter++;
            }
        }
        // Returns the array of owned zombie IDs
        return result;
    }

}
