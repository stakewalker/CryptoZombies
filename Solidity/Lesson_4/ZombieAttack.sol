// Specifies the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieHelper contract
import "./ZombieHelper.sol";

// ZombieAttack contract, inheriting from ZombieHelper
contract ZombieAttack is ZombieHelper {

    // Nonce for generating random numbers
    uint randNonce = 0;
    // Probability of winning an attack (in percentage)
    uint attackVictoryProbability = 70;

    // Internal function to generate a random number modulo _modulus
    function randMod(uint _modulus) internal returns(uint) {
        // Incrementing the nonce to avoid repeated random numbers
        randNonce++;
        // Generating a random number based on current time, sender address, and nonce
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }

    // External function for a zombie to attack another zombie
    function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {
        // Retrieving references to the attacking and defending zombies
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        // Generating a random number to determine the outcome of the attack
        uint rand = randMod(100);

        // If the random number is within the attackVictoryProbability, the attack is successful
        if (rand <= attackVictoryProbability) {
            // Updating stats for the attacking zombie
            myZombie.winCount++;
            myZombie.level++;
            // Updating stats for the defending zombie
            enemyZombie.lossCount++;
            // Feeding and potentially multiplying the attacking zombie
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        }
        // Attack outcome is not explicitly handled for cases where the attack fails
        // In a real-world scenario, you might want to add logic for unsuccessful attacks
    }
}
