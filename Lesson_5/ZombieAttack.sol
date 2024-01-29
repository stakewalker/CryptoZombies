// pragma directive specifying the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieHelper contract
import "./ZombieHelper.sol";

// ZombieAttack contract, inheriting from ZombieHelper
contract ZombieAttack is ZombieHelper {
    // State variables for random number generation and attack victory probability
    uint randNonce = 0;
    uint attackVictoryProbability = 70;

    // Internal function to generate a random number modulo _modulus
    function randMod(uint _modulus) internal returns(uint) {
        // Incrementing the nonce for uniqueness
        randNonce = randNonce.add(1);
        // Generating a random number based on current time, sender address, and nonce
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
    }

    // External function for a zombie to attack another zombie
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        // Retrieving references to the attacking and defending zombies
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        // Generating a random number to determine the outcome of the attack
        uint rand = randMod(100);

        // If the random number is within the attackVictoryProbability, the attack is successful
        if (rand <= attackVictoryProbability) {
            // Updating stats for the attacking zombie in case of victory
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            // Updating stats for the defending zombie in case of defeat
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            // Feeding and potentially multiplying the attacking zombie
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            // Updating stats for the attacking zombie in case of defeat
            myZombie.lossCount = myZombie.lossCount.add(1);
            // Updating stats for the defending zombie in case of victory
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            // Triggering the cooldown for the attacking zombie
            _triggerCooldown(myZombie);
        }
    }
}
