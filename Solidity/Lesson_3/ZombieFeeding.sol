// Specifying the Solidity compiler version to be used
pragma solidity >=0.5.0 <0.6.0;

// Importing another Solidity file
import "./ZombieFactory.sol";

// Interface contract for the Kitty contract
contract KittyInterface {
    // Declaring the getKitty function signature that is expected in the Kitty contract
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

// ZombieFeeding contract, inheriting from the ZombieFactory contract
contract ZombieFeeding is ZombieFactory {

    // Variable to hold the KittyInterface contract instance
    KittyInterface kittyContract;

    // Function to set the Kitty contract address, can only be called by the contract owner
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // Internal function to start a cooldown period for a zombie after it feeds
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // Public function to feed a zombie and potentially mutate its DNA
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
        // Ensures the caller is the owner of the zombie
        require(msg.sender == zombieToOwner[_zombieId]);
        // References the feeding zombie from the zombies array
        Zombie storage myZombie = zombies[_zombieId];
        // Adjusts target DNA to fit DNA modulus
        _targetDna = _targetDna % dnaModulus;
        // Averages the DNA of myZombie and target
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // If the species is 'kitty', adjust the last two digits of DNA
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        // Creates a new zombie with the resultant DNA
        _createZombie("NoName", newDna);
        // Triggers the cooldown for the zombie
        _triggerCooldown(myZombie);
    }

    // Public function to allow a zombie to feed on a kitty
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        // Extracting the kitty's DNA using the getKitty function from KittyInterface
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        // Calls feedAndMultiply function with the kitty's DNA
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}
