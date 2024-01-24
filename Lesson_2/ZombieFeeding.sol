// Specifies the compatible Solidity compiler versions for this contract
pragma solidity >=0.5.0 <0.6.0;

// Importing another contract file
import "./ZombieFactory.sol";

// Interface for the Kitty contract to interact with it
contract KittyInterface {
  // Declaring a function signature that exists in the Kitty contract
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

// Contract inheriting from ZombieFactory to add feeding functionality
contract ZombieFeeding is ZombieFactory {

  // Address of the CryptoKitties contract
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  // Creating an instance of the KittyInterface
  KittyInterface kittyContract = KittyInterface(ckAddress);

  // Function to feed a zombie and potentially mutate its DNA
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
    // Ensure only the owner of the zombie can feed it
    require(msg.sender == zombieToOwner[_zombieId]);
    // Reference to the feeding zombie
    Zombie storage myZombie = zombies[_zombieId];
    // Modulus operator to ensure DNA stays within the limit
    _targetDna = _targetDna % dnaModulus;
    // Create new DNA by averaging the zombie's DNA and the target's DNA
    uint newDna = (myZombie.dna + _targetDna) / 2;
    // If the species is a kitty, modify the last two digits of DNA
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    // Create a new zombie from the new DNA
    _createZombie("NoName", newDna);
  }

  // Function to allow a zombie to feed on a kitty
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    // Getting the kitty's DNA from the Kitty contract
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    // Calling feedAndMultiply with the kitty's DNA
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}
