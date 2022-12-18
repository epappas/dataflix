//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Dataflix is ERC1155, Ownable {
    using SafeMath for uint256;

    struct Datasource {
        string name;
        string resourceUri;
        string policyUri;
        uint256 price;
        uint256 subscriptions;
        uint256 expirationTime;
    }

    struct Subscription {
        address subscriber;
        uint256 datasource;
        string principalUri;
        uint256 createdAt;
    }

    mapping(uint256 => Datasource) internal datasources;
    mapping(uint256 => Subscription) internal subscriptions;
    mapping(address => uint256[]) internal subscribers;

    string public name;
    string public symbol;
    uint256 public totalDatasources;
    uint256 public totalSubscriptions;

    event NewDatasource(uint256 datasourceId);
    event DatasourceUpdated(uint256 datasourceId);

    event NewSubscription(
        address indexed subscriber,
        uint256 indexed datasourceId,
        uint256 indexed subscriptionId
    );

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;
    }

    modifier correctId(uint256 id) {
        require(
            id <= totalDatasources && id > 0,
            "provide a correct datasourceID"
        );
        _;
    }

    modifier datasourceExists(uint256 id) {
        require(
            datasources[id].expirationTime != 0,
            "provide a correct datasourceID"
        );
        _;
    }

    modifier correctPrice(uint256 id) {
        require(
            msg.value == datasources[id].price,
            "please send correct amount of ether"
        );
        _;
    }

    modifier notExpired(uint256 datasourceId, uint256 createdAt) {
        require(
            block.timestamp <
                (datasources[datasourceId].expirationTime + createdAt),
            "The subscription is expired"
        );
        _;
    }

    modifier validSubscription(address user, uint256 subscriptionId) {
        require(
            subscriptions[subscriptionId].createdAt != 0 &&
                subscriptions[subscriptionId].subscriber == user &&
                subscribers[user].length > 0,
            "doesn't have any active subscription"
        );
        require(
            (block.timestamp).sub(subscriptions[subscriptionId].createdAt) <
                datasources[subscriptions[subscriptionId].datasource]
                    .expirationTime,
            "doesn't have any active datasource"
        );
        _;
    }

    function setURI(string memory uri) external onlyOwner {
        _setURI(uri);
    }

    function addDatasource(
        string memory _name,
        string memory resourceUri,
        string memory policyUri,
        uint256 price,
        uint256 time
    ) external onlyOwner {
        uint256 id = totalDatasources.add(1);
        totalDatasources = totalDatasources.add(1);

        datasources[id] = Datasource(
            _name,
            resourceUri,
            policyUri,
            0,
            price,
            time
        );

        emit NewDatasource(id);
    }

    function updateDatasource(
        uint256 id,
        string memory _name,
        string memory resourceUri,
        string memory policyUri,
        uint256 price,
        uint256 time
    ) external onlyOwner datasourceExists(id) {
        datasources[id] = Datasource(
            _name,
            resourceUri,
            policyUri,
            datasources[id].subscriptions,
            price,
            time
        );

        emit DatasourceUpdated(id);
    }

    function subscribe(uint256 datasourceId, string memory principalUri)
        external
        payable
        correctId(datasourceId)
        datasourceExists(datasourceId)
        correctPrice(datasourceId)
    {
        uint256 id = totalSubscriptions.add(1);
        totalSubscriptions = totalSubscriptions.add(1);

        datasources[datasourceId].subscriptions = (
            datasources[datasourceId].subscriptions
        ).add(1);

        subscriptions[id] = Subscription(
            msg.sender,
            datasourceId,
            principalUri,
            block.timestamp
        );

        subscribers[msg.sender].push(id);

        // destroys the user’s NFTs for any inactive datasources using the _burn function.
        _burn(msg.sender, datasourceId, balanceOf(msg.sender, datasourceId));

        _mint(msg.sender, datasourceId, 1, "");
        payable(msg.sender).transfer(msg.value);

        emit NewSubscription(msg.sender, datasourceId, id);
    }

    function selectSubscriptions(address user)
        public
        view
        returns (uint256[] memory)
    {
        return subscribers[user];
    }

    function selectDatasource(address user, uint256 subscriptionId)
        public
        view
        validSubscription(user, subscriptionId)
        returns (uint256)
    {
        return subscriptions[subscriptionId].datasource;
    }

    function tokenURI(uint256 id)
        public
        view
        correctId(id)
        returns (string memory)
    {
        return datasources[id].resourceUri;
    }

    function tokenSupply(uint256 id)
        public
        view
        correctId(id)
        returns (uint256)
    {
        return datasources[id].subscriptions;
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
        return totalSubscriptions;
    }

    function balance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "transfer failed");
    }
}
