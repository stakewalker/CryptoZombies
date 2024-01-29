// pragma directive specifying the Solidity compiler version range
pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieFactory contract
import "./ZombieFactory.sol";

// Interface for interacting with the CryptoKitties contract
contract KittyInterface {
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

    // Reference to the KittyInterface contract
    KittyInterface kittyContract;

    // Modifier to ensure the caller is the owner of the specified zombie
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;    // Continues execution of the modified function
    }

    // Function to set the address of the CryptoKitties contract
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // Internal function to trigger the cooldown for a zombie
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // Internal function to check if a zombie is ready for action
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }

    // Internal function for a zombie to feed on another entity and potentially multiply
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        // Ensure the zombie is ready for action
        require(_isReady(myZombie));
        // Ensure the target DNA is within valid bounds
        _targetDna = _targetDna % dnaModulus;
        // Calculate the new DNA by combining the zombie's DNA and the target DNA
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // If the target species is a "kitty," modify the new DNA
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        // Create a new zombie with the modified DNA
        _createZombie("NoName", newDna);
        // Trigger the cooldown for the feeding zombie
        _triggerCooldown(myZombie);
    }

    // Function for a zombie to feed on a CryptoKitty
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        // Declare a variable to store the DNA of the CryptoKitty
        uint kittyDna;
        // Call the getKitty function from the KittyInterface to retrieve the DNA
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        // Feed the zombie on the CryptoKitty, potentially multiplying
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
