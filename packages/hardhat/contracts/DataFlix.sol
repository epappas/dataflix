pragma solidity >=0.8.4;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Dataflix is ERC1155, Ownable {
    using SafeMath for uint256;

    struct Datasource {
        string name;
        string uri;
        uint256 subscribers;
        uint256 price;
        uint256 time;
    }

    struct Subscriber {
        uint256 datasource;
        uint256 date;
    }

    mapping(uint256 => Datasource) internal datasources;

    mapping(address => Subscriber) internal subscribers;

    uint256 public totalDatasources;

    constructor(
        string memory name,
        string memory symbol,
        string memory uri
    ) ERC1155(uri) {}

    modifier correctId(uint256 id) {
        require(
            id <= totalDatasources && id > 0,
            "provide a correct datasourceID"
        );
        _;
    }

    function setURI(string memory uri) external onlyOwner {
        _setURI(uri);
    }

    function ifExpired(uint256 id) internal view returns (bool) {
        if (subscribers[msg.sender].datasource == id) {
            if (
                (block.timestamp).sub(subscribers[msg.sender].date) <
                datasources[id].time
            ) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    function addDatasource(
        string memory _name,
        string memory uri,
        uint256 price,
        uint256 time
    ) external onlyOwner {
        totalDatasources = totalDatasources.add(1);
        uint256 id = totalDatasources.add(1);
        datasources[id] = Datasource(_name, uri, 0, price, time);
    }

    function updateDatasource(
        uint256 id,
        string memory _name,
        string memory uri,
        uint256 price,
        uint256 time
    ) external onlyOwner {
        datasources[id] = Datasource(
            _name,
            uri,
            datasources[id].subscribers,
            price,
            time
        );
    }

    function subscribe(uint256 datasourceId)
        external
        payable
        correctId(datasourceId)
    {
        require(
            ifExpired(datasourceId) == true,
            "your current datasource hasn't expired yet"
        );
        require(
            msg.value == datasources[datasourceId].price,
            "please send correct amount of ether"
        );

        datasources[datasourceId].subscribers = (
            datasources[datasourceId].subscribers
        ).add(1);
        subscribers[msg.sender] = Subscriber(datasourceId, block.timestamp);

        // destroys the user’s NFTs for any inactive datasources using the _burn function.
        _burn(
            msg.sender,
            subscribers[msg.sender].datasource,
            balanceOf(msg.sender, subscribers[msg.sender].datasource)
        );

        datasources[subscribers[msg.sender].datasource].subscribers = (
            datasources[subscribers[msg.sender].datasource].subscribers
        ).sub(balanceOf(msg.sender, subscribers[msg.sender].datasource));

        _mint(msg.sender, datasourceId, 1, "");
        payable(msg.sender).transfer(msg.value);
    }

    function currentDatasource(address user) public view returns (uint256) {
        require(
            (block.timestamp).sub(subscribers[msg.sender].date) <
                datasources[subscribers[msg.sender].datasource].time,
            "doesn't have any active datasource"
        );
        return subscribers[user].datasource;
    }

    function tokenURI(uint256 id)
        public
        view
        correctId(id)
        returns (string memory)
    {
        return datasources[id].uri;
    }

    function tokenSupply(uint256 id)
        public
        view
        correctId(id)
        returns (uint256)
    {
        return datasources[id].subscribers;
    }

    function tokenPrice(uint256 id)
        public
        view
        correctId(id)
        returns (uint256)
    {
        return datasources[id].price;
    }

    function totalSupply() public view returns (uint256) {
        return totalDatasources;
    }

    function balance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "transfer failed");
    }
}
