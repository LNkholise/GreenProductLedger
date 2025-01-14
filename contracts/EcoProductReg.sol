// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EcoProductRegistry is Ownable {
    struct Stage {
        string stageDescription;
        uint256 timestamp;
    }

    struct Product {
        string name;
        string[] materials;
        uint256 carbonFootprintKg;
        uint8 ecoScore;
        bool recyclable;
        string disposalInstructions;
        address verifier; // Address of the verifier
        uint256 traceabilityCount; // Track number of traceability stages
    }

    constructor() public Ownable(msg.sender) {}

    mapping(uint256 => Product) public products;
    mapping(uint256 => mapping(uint256 => Stage)) public productStages; // Mapping to store stages for each product
    uint256 public nextProductId;

    event ProductAdded(uint256 productId, string name, address verifier);
    event ProductStageUpdated(uint256 productId, string stage, uint256 timestamp);

    // Add a new product to the registry
    function addProduct(
        string memory _name,
        string[] memory _materials,
        uint256 _carbonFootprintKg,
        uint8 _ecoScore,
        bool _recyclable,
        string memory _disposalInstructions,
        address _verifier
    ) public onlyOwner {
        require(_ecoScore <= 100, "ecoScore must be between 0 and 100");
        require(_verifier != address(0), "Verifier address cannot be zero");

        products[nextProductId] = Product(
            _name,
            _materials,
            _carbonFootprintKg,
            _ecoScore,
            _recyclable,
            _disposalInstructions,
            _verifier,
            0 // initialize the traceability count to 0
        );

        emit ProductAdded(nextProductId, _name, _verifier);

        nextProductId++;
    }

    // Retrieve product details
    function getProduct(uint256 _productId)
        public
        view
        returns (
            string memory name,
            string[] memory materials,
            uint256 carbonFootprintKg,
            uint8 ecoScore,
            bool recyclable,
            string memory disposalInstructions,
            address verifier,
            Stage[] memory traceability
        )
    {
        require(_productId < nextProductId, "Product does not exist");

        Product memory product = products[_productId];
        uint256 traceabilityLength = product.traceabilityCount;
        traceability = new Stage[](traceabilityLength);

        for (uint256 i = 0; i < traceabilityLength; i++) {
            traceability[i] = productStages[_productId][i];
        }

        return (
            product.name,
            product.materials,
            product.carbonFootprintKg,
            product.ecoScore,
            product.recyclable,
            product.disposalInstructions,
            product.verifier,
            traceability
        );
    }

    // Adding a new stage to the product's traceability history with timestamp
    function addProductStage(uint256 _productId, string memory _stage) public {
        require(_productId < nextProductId, "Product does not exist");
        require(
            msg.sender == products[_productId].verifier,
            "Only the verifier can update traceability"
        );

        uint256 currentTimestamp = block.timestamp; // Getting the current timestamp
        uint256 traceabilityIndex = products[_productId].traceabilityCount;

        productStages[_productId][traceabilityIndex] = Stage(_stage, currentTimestamp);
        products[_productId].traceabilityCount++;

        emit ProductStageUpdated(_productId, _stage, currentTimestamp);
    }
}
