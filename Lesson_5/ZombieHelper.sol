// pragma directive specifying the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieFeeding contract
import "./ZombieFeeding.sol";

// ZombieHelper contract, inheriting from ZombieFeeding
contract ZombieHelper is ZombieFeeding {

    // Fee required to level up a zombie
    uint levelUpFee = 0.001 ether;

    // Modifier to check if a zombie's level is above a specified level
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;    // Continues execution of the modified function
    }

    // Function for the contract owner to withdraw funds from the contract
    function withdraw() external onlyOwner {
        // Transfer the contract's balance to the owner
        address _owner = owner();
        _owner.transfer(address(this).balance);
    }

    // Function for the contract owner to set the level up fee
    function setLevelUpFee(uint _fee) external onlyOwner {
        // Update the level up fee
        levelUpFee = _fee;
    }

    // Function for a zombie to level up, requiring payment of the levelUpFee
    function levelUp(uint _zombieId) external payable {
        // Ensure the sent value matches the levelUpFee
        require(msg.value == levelUpFee);
        // Increment the level of the specified zombie
        zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    }

    // Function to change the name of a zombie, requiring the zombie to be at least level 2
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        // Update the name of the specified zombie
        zombies[_zombieId].name = _newName;
    }

    // Function to change the DNA of a zombie, requiring the zombie to be at least level 20
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        // Update the DNA of the specified zombie
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
