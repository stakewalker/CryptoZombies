/// @title CryptoZombies Lesson 5
/// @author StakeWalker
/// @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft

pragma solidity >=0.5.0 <0.6.0;

// Importing the ZombieAttack contract, ERC721 contract, and SafeMath library
import "./ZombieAttack.sol";
import "./erc721.sol";
import "./SafeMath.sol";

// ZombieOwnership contract, inheriting from ZombieAttack and implementing ERC721
contract ZombieOwnership is ZombieAttack, ERC721 {

    // Using SafeMath for safe arithmetic operations on uint256
    using SafeMath for uint256;

    // Mapping to store zombie approvals by tokenId
    mapping (uint => address) zombieApprovals;

    // Function to get the balance of zombies owned by a specific address
    function balanceOf(address _owner) external view returns (uint256) {
        return ownerZombieCount[_owner];
    }

    // Function to get the owner of a specific zombie by tokenId
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return zombieToOwner[_tokenId];
    }

    // Internal function to transfer ownership of a zombie from one address to another
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // Incrementing the zombie count for the new owner
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        // Decrementing the zombie count for the previous owner
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        // Updating the zombie ownership mapping
        zombieToOwner[_tokenId] = _to;
        // Emitting a Transfer event
        emit Transfer(_from, _to, _tokenId);
    }

    // Function to transfer ownership of a zombie from one address to another
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        // Checking if the caller is the owner or an approved address
        require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        // Performing the ownership transfer
        _transfer(_from, _to, _tokenId);
    }

    // Function to approve another address to transfer the ownership of a zombie
    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
        // Setting the approved address for the zombie
        zombieApprovals[_tokenId] = _approved;
        // Emitting an Approval event
        emit Approval(msg.sender, _approved, _tokenId);
    }

}
