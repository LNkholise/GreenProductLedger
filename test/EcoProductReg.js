const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EcoProductRegistry", function () {
  let EcoProductRegistry;
  let ecoProductRegistry;
  let owner;
  let verifier;

  before(async function () {
    // Get signers (accounts) from ethers
    [owner, verifier] = await ethers.getSigners();

    // Deploy the contract
    const EcoProductRegistryFactory = await ethers.getContractFactory("EcoProductRegistry");
    ecoProductRegistry = await EcoProductRegistryFactory.deploy();
  
    await ecoProductRegistry.deployed;
  });

  it("Should add a product successfully", async function () {
    const productName = "Eco-Friendly Bag";
    const materials = ["Cotton", "Recycled Plastic"];
    const carbonFootprint = 500; // in kg
    const ecoScore = 90;
    const recyclable = true;
    const disposalInstructions = "Recycle with plastics";
    const verifierAddress = verifier.address;

    // Add a product to the registry
    await ecoProductRegistry.addProduct(
      productName,
      materials,
      carbonFootprint,
      ecoScore,
      recyclable,
      disposalInstructions,
      verifierAddress
    );

    // Verify the product was added by checking the first product (ID 0)
    const product = await ecoProductRegistry.getProduct(0);
    expect(product.name).to.equal(productName);
    expect(product.carbonFootprintKg.toString()).to.equal(carbonFootprint.toString());
    expect(product.recyclable).to.equal(recyclable);
    expect(product.verifier).to.equal(verifierAddress);
    expect(product.materials.length).to.equal(materials.length);
    expect(product.materials[0]).to.equal(materials[0]);
  });

  it("Should retrieve product details correctly", async function () {
    const productId = 0;
    
    const product = await ecoProductRegistry.getProduct(productId);

    // Verify the product details
    expect(product.name).to.equal("Eco-Friendly Bag");
    expect(product.carbonFootprintKg.toString()).to.equal("500");
    expect(product.ecoScore).to.equal(90);
    expect(product.recyclable).to.equal(true);
    expect(product.disposalInstructions).to.equal("Recycle with plastics");
    expect(product.verifier).to.equal(verifier.address);
    expect(product.materials.length).to.equal(2); // Since we added two materials
    expect(product.materials[0]).to.equal("Cotton");
    expect(product.materials[1]).to.equal("Recycled Plastic");

    // Verify that traceability is empty initially
    expect(product.traceability.length).to.equal(0);
  });

  it("Should add a stage to the product's traceability history", async function () {
    const productId = 0;
    const stage = "Manufacturing stage completed";
    
    await ecoProductRegistry.connect(verifier).addProductStage(productId, stage);

    const product = await ecoProductRegistry.getProduct(productId);

    expect(product.traceability.length).to.equal(1);

    expect(product.traceability[0].stageDescription).to.equal(stage);

    expect(product.traceability[0].timestamp).to.be.greaterThan(0);
  });

  it("Should fail if a non-verifier tries to add a stage", async function () {
    const productId = 0;
    const stage = "Shipping stage completed";

    await expect(
      ecoProductRegistry.connect(owner).addProductStage(productId, stage)
    ).to.be.revertedWith("Only the verifier can update traceability");
  });
});
