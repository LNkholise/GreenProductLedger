// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EcoProductRegistry {
    struct Product {
        string name;
        string[] materials;
        uint256 carbonFootprintKg;
        uint8 ecoScore;
        bool recyclable;
        string disposalInstructions;
    }

    mapping(uint256 => Product) public products;
    uint256 public nextProductId;

    event ProductAdded(uint256 productId, string name);

    function addProduct(
        string memory _name,
        string[] memory _materials,
        uint256 _carbonFootprintKg,
        uint8 _ecoScore,
        bool _recyclable,
        string memory _disposalInstructions
    ) public {
        require(_ecoScore <= 100, "ecoScore must be between 0 and 100");

        products[nextProductId] = Product(
            _name,
            _materials,
            _carbonFootprintKg,
            _ecoScore,
            _recyclable,
            _disposalInstructions
        );

        emit ProductAdded(nextProductId, _name);

        nextProductId++;
    }

    function getProduct(uint256 _productId)
        public
        view
        returns (
            string memory name,
            string[] memory materials,
            uint256 carbonFootprintKg,
            uint8 ecoScore,
            bool recyclable,
            string memory disposalInstructions
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
            product.disposalInstructions
        );
    }
}

