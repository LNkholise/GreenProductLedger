// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract EcoProductRegistry is Ownable {
    struct Product {
        string name;
        string[] materials;
        uint256 carbonFootprintKg;
        uint8 ecoScore;
        bool recyclable;
        string disposalInstructions;
        address verifier; // Address of the verifier
        string[] traceability; // History of product stages
    }

    constructor() public Ownable(msg.sender) {}
    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    event ProductAdded(uint256 productId, string name, address verifier);
    event ProductStageUpdated(uint256 productId, string stage);

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
            new string[](0) //initialize the array of strings
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
            string[] memory traceability
        )
    {
        require(_productId < nextProductId, "Product does not exist");

        Product memory product = products[_productId];
        return (
            product.name,
            product.materials,
            product.carbonFootprintKg,
            product.ecoScore,
            product.recyclable,
            product.disposalInstructions,
            product.verifier,
            product.traceability
        );
    }

    // Add a new stage to the product's traceability history
    function addProductStage(uint256 _productId, string memory _stage) public {
        require(_productId < nextProductId, "Product does not exist");
        require(
            msg.sender == products[_productId].verifier,
            "Only the verifier can update traceability"
        );

        products[_productId].traceability.push(_stage);

        emit ProductStageUpdated(_productId, _stage);
    }
}

