const { expect } = require("chai");

describe("EcoProductRegistry", function () {
  let EcoProductRegistry;
  let ecoProductRegistry;
  let owner;

  beforeEach(async () => {
    [owner] = await ethers.getSigners();
    EcoProductRegistry = await ethers.getContractFactory("EcoProductRegistry");
    ecoProductRegistry = await EcoProductRegistry.deploy();
  });

  describe("addProduct", function () {
    it("should add a product and emit the ProductAdded event", async function () {
      const name = "Eco Friendly Water Bottle";
      const materials = ["BPA-free plastic", "Recycled aluminum"];
      const carbonFootprintKg = 1;
      const ecoScore = 80;
      const recyclable = true;
      const disposalInstructions = "Please recycle the bottle.";

      // Add the product
      await expect(
        ecoProductRegistry.addProduct(
          name,
          materials,
          carbonFootprintKg,
          ecoScore,
          recyclable,
          disposalInstructions
        )
      )
        .to.emit(ecoProductRegistry, "ProductAdded")
        .withArgs(0, name); // Check if the event is emitted correctly with the expected arguments

      const product = await ecoProductRegistry.getProduct(0);

      // Verify that the product was added correctly
      expect(product.name).to.equal(name);
      expect(product.materials).to.deep.equal(materials);
      expect(product.carbonFootprintKg).to.equal(carbonFootprintKg);
      expect(product.ecoScore).to.equal(ecoScore);
      expect(product.recyclable).to.equal(recyclable);
      expect(product.disposalInstructions).to.equal(disposalInstructions);
    });

    it("should revert when ecoScore is greater than 100", async function () {
      const name = "Eco Friendly Water Bottle";
      const materials = ["BPA-free plastic", "Recycled aluminum"];
      const carbonFootprintKg = 1;
      const ecoScore = 101; // Invalid ecoScore
      const recyclable = true;
      const disposalInstructions = "Please recycle the bottle.";

      // Expect the transaction to revert due to ecoScore validation
      await expect(
        ecoProductRegistry.addProduct(
          name,
          materials,
          carbonFootprintKg,
          ecoScore,
          recyclable,
          disposalInstructions
        )
      ).to.be.revertedWith("ecoScore must be between 0 and 100");
    });
  });

  describe("getProduct", function () {
    it("should retrieve the correct product", async function () {
      const name = "Eco Friendly Water Bottle";
      const materials = ["BPA-free plastic", "Recycled aluminum"];
      const carbonFootprintKg = 1;
      const ecoScore = 80;
      const recyclable = true;
      const disposalInstructions = "Please recycle the bottle.";

      await ecoProductRegistry.addProduct(
        name,
        materials,
        carbonFootprintKg,
        ecoScore,
        recyclable,
        disposalInstructions
      );

      const product = await ecoProductRegistry.getProduct(0);

      // Verify product data after adding it
      expect(product.name).to.equal(name);
      expect(product.materials).to.deep.equal(materials);
      expect(product.carbonFootprintKg).to.equal(carbonFootprintKg);
      expect(product.ecoScore).to.equal(ecoScore);
      expect(product.recyclable).to.equal(recyclable);
      expect(product.disposalInstructions).to.equal(disposalInstructions);
    });

    it("should revert if the product does not exist", async function () {
      // Expect revert when trying to get a non-existing product
      await expect(ecoProductRegistry.getProduct(999)).to.be.revertedWith(
        "Product does not exist"
      );
    });
  });
});

