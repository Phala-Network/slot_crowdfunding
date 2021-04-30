#!/usr/bin/env node

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')

const argv = yargs(hideBin(process.argv))
  .option('para-id', {
    alias: 'id',
    type: 'integer'
  })
  .option('block-number', {
    alias: 'at',
    type: 'integer'
  })
  .argv

require('dotenv').config();

const { ApiPromise, WsProvider } = require('@polkadot/api');
const { hexToU8a, isHex } = require('@polkadot/util')
const BN = require('bn.js');

const bn1e9 = new BN(10).pow(new BN(9));
const amountToFloat = (amount) => {
  const bnAmount = typeof amount == "string" && isHex(amount) ? new BN(hexToU8a(amount), "hex") : new BN(amount)
  return bnAmount.div(bn1e9).toNumber() / 1e3
}

(async() => {
  try {
    const wsProvider = new WsProvider(process.env.ENDPOINT)
    const api = await ApiPromise.create({
      provider: wsProvider
    })

    const paraId = argv["para-id"]
    const blockNumber = argv["block-number"]

    let blockHash = null
    if (blockNumber && blockNumber > 0) {
      blockHash = await api.rpc.chain.getBlockHash(blockNumber)
    }

    const fundInfo = blockHash ? await api.query.crowdloan.funds.at(blockHash, paraId) : await api.query.crowdloan.funds(paraId)
    const jsonValue = fundInfo.toJSON()

    if (!jsonValue) {
      process.exit(0)
    }

    // Shall I take care of BigNumber overflow ???
    const newJson = {
      deposit: amountToFloat(jsonValue.deposit),
      raised: amountToFloat(jsonValue.raised),
      cap: amountToFloat(jsonValue.cap),
      end: jsonValue.end,
      depositor: jsonValue.depositor
    }

    // console.log(jsonValue)
    // console.log(newJson)

    console.log(JSON.stringify(newJson))
    process.exit(0)
  } catch (err) {
    console.error(err);
    process.exit(1)
  }
})();
