#!/usr/bin/env node

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')

const argv = yargs(hideBin(process.argv))
  .option('block-number', {
    alias: 'at',
    type: 'integer'
  })
  .option('endpoint')
  .demandOption(['endpoint'])
  .argv

require('dotenv').config();

const { HttpProvider } = require('@polkadot/rpc-provider/http');
const { ApiPromise, WsProvider } = require('@polkadot/api');
const { hexToU8a, isHex } = require('@polkadot/util')
const BN = require('bn.js');
const { typedefs } = require('./typedefs')

const bn1e9 = new BN(10).pow(new BN(9));
const amountToFloat = (amount) => {
  const bnAmount = typeof amount == "string" && isHex(amount) ? new BN(hexToU8a(amount), "hex") : new BN(amount)
  return bnAmount.div(bn1e9).toNumber() / 1e3
}

(async() => {
  try {
    const endpoint = argv["endpoint"]
    const blockNumber = argv["block-number"]

    let provider = null;
    if (endpoint.startsWith('wss://') || endpoint.startsWith('ws://')) {
      provider = new WsProvider(endpoint)
    } else if (endpoint.startsWith('https://') || endpoint.startsWith('http://')) {
      provider = new HttpProvider(endpoint)
    } else {
      console.warn(`Invalid endpoint ${endpoint}`)
      process.exit(1)
    }

    const api = await ApiPromise.create({
      provider: provider,
      types: typedefs
    })

    let blockHash = null
    if (blockNumber && blockNumber > 0) {
      blockHash = await api.rpc.chain.getBlockHash(blockNumber)
    }

    let fundInfos = {};
    const fundInfoEntries = blockHash ? await api.query.crowdloan.funds.entriesAt(blockHash) : await api.query.crowdloan.funds.entries()
    for (let [k, v] of fundInfoEntries) {
      const jsonValue = v.toJSON()

      // Shall I take care of BigNumber overflow ???
      fundInfos[k.toHuman()[0]] = {
        deposit: amountToFloat(jsonValue.deposit),
        raised: amountToFloat(jsonValue.raised),
        cap: amountToFloat(jsonValue.cap),
        end: jsonValue.end,
        depositor: jsonValue.depositor
      }

      // console.log(jsonValue)
      // console.log(fundInfos[k.toHuman()[0]])
    }

    // console.log(fundInfos)

    console.log(JSON.stringify(fundInfos))
    process.exit(0)
  } catch (err) {
    console.error(err);
    process.exit(1)
  }
})();
