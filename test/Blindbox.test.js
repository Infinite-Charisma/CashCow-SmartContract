const { expectRevert } = require("@openzeppelin/test-helpers");
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");

const Blindbox = artifacts.require('Blindbox');
const MilkToken = artifacts.require('MilkToken');
const Market = artifacts.require('Market');

const { toWei, toBN } = web3.utils;
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

contract('BlindBox', function ([alice, bob, david, carol, eve, paul, ben]) {
    before(async function () {
        this.milkToken = await MilkToken.new({ from: alice });
        console.log(this.milkToken.address);
        this.market = await Market.new(this.milkToken.address, { from: alice });
        this.blindbox = await Blindbox.new(1, "Happy Cows", "HCN", 1636910194, this.milkToken.address, 1000, { from: alice });
        console.log(this.blindbox.address);
        console.log(this.market.address);
        console.log('Set Initialize the blindbox');

        this.milkToken.transfer(david, toWei('1000', 'gwei'), { from: alice });
        this.milkToken.transfer(carol, toWei('1000', 'gwei'), { from: alice });
        this.milkToken.transfer(eve, toWei('1000', 'gwei'), { from: alice });
        this.milkToken.transfer(paul, toWei('1000', 'gwei'), { from: alice });
        this.milkToken.transfer(ben, toWei('1000', 'gwei'), { from: alice });
    });

    context("Test setLockTime", () => {
        it("should success to set the locktime", async function () {
            await this.blindbox.setLockTime(1636910194, { from: alice });
            const startTime = await this.blindbox.startTime();
            assert.equal(startTime.toString(), "1636910194");
        })
    });

    context("Test Buy BlindBox function", () => {
        it("Should success to buy blindbox by David", async function () {
            await this.milkToken.approve(this.blindbox.address, 10000, { from: david });
            await this.blindbox.buyBlindBox("https://ipfs.url", this.market.address, { from: david });

            const totalSupply = await this.blindbox.totalSupply();
            assert.equal(totalSupply.toString(), '1');

            const balanceOfBlindBox = await this.milkToken.balanceOf(this.blindbox.address);
            assert.equal(balanceOfBlindBox.toString(), "10000");
        });
        it("Should success to buy blindbox by Carol", async function () {
            await this.milkToken.approve(this.blindbox.address, 10000, { from: carol });
            await this.blindbox.buyBlindBox("https://ipfs.url", this.market.address, { from: carol });

            const totalSupply = await this.blindbox.totalSupply();
            assert.equal(totalSupply.toString(), '2');

            const balanceOfBlindBox = await this.milkToken.balanceOf(this.blindbox.address);
            assert.equal(balanceOfBlindBox.toString(), "20000");
        });
    });
})
