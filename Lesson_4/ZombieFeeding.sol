// Specifies the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieFactory contract
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

// ZombieFeeding contract, inheriting from ZombieFactory
contract ZombieFeeding is ZombieFactory {

    // Variable to hold the KittyInterface contract instance
    KittyInterface kittyContract;

    // Modifier to check if the caller is the owner of the specified zombie
    modifier ownerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;    // Continues execution of the modified function
    }

    // Function to set the Kitty contract address, can only be called by the contract owner
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // Internal function to start a cooldown period for a zombie after it feeds
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // Internal function to check if a zombie is ready for another action
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
            return (_zombie.readyTime <= now);
    }

    // Internal function for a zombie to feed and potentially multiply
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal ownerOf(_zombieId) {
        // Reference to the feeding zombie
        Zombie storage myZombie = zombies[_zombieId];
        // Ensure the zombie is ready for another action
        require(_isReady(myZombie));
        // Trim the target DNA to fit DNA modulus
        _targetDna = _targetDna % dnaModulus;
        // Calculate the new DNA by averaging the current zombie's DNA and the target DNA
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // If the species is 'kitty', adjust the last two digits of DNA
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        // Create a new zombie with the resultant DNA
        _createZombie("NoName", newDna);
        // Trigger the cooldown for the feeding zombie
        _triggerCooldown(myZombie);
    }

    // Public function to allow a zombie to feed on a kitty
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        // Variable to store the DNA of the kitty
        uint kittyDna;
        // Extracting the kitty's DNA using the getKitty function from KittyInterface
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        // Calls feedAndMultiply function with the kitty's DNA
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
