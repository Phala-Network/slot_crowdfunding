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
  .option('endpoint')
  .demandOption(['endpoint'])
  .argv

require('dotenv').config();

const EXTRINSIC_BATCH = new Uint8Array([8, 90, 0])

const { HttpProvider } = require('@polkadot/rpc-provider/http');
const { ApiPromise, WsProvider } = require('@polkadot/api');
const { hexToU8a, isHex } = require('@polkadot/util');
const BN = require('bn.js');
const { getReferrerFromRemark } = require('./referrer_remark');
const { typedefs } = require('./typedefs')

const bn1e9 = new BN(10).pow(new BN(9));
const amountToFloat = (amount) => {
  const bnAmount = typeof amount == "string" && isHex(amount) ? new BN(hexToU8a(amount), "hex") : new BN(amount)
  return bnAmount.div(bn1e9).toNumber() / 1e3
}

// {
//   method: 'Transfer',
//     section: 'balances',
//   index: '0x0402',
//   data: [
//   '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
//   '5EYCAe5ijiYdg22N9CedBJtJvwVZs7pCbmaPecB2ajMEDfXa',
//   '150.0000 Unit'
// ]
// }
// {
//   method: 'Contributed',
//     section: 'crowdloan',
//   index: '0x2a01',
//   data: [
//   '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
//   '30',
//   '150.0000 Unit'
// ]
// }

(async () => {
  try {
    const endpoint = argv["endpoint"]
    const paraId = argv["para-id"]
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
      blockHash = await api.rpc.chain.getBlockHash(blockNumber).catch(err => {
        const noBlockErrorPattern = "createType(BlockHash):: Cannot read property 'subarray' of null";
        if (err.message === noBlockErrorPattern) {
          return null
        }
      })
    }

    if (blockHash == null) {
      console.warn(`Can't get blockHash because block-number ${blockNumber} not found`)
      process.exit(0)
    }

    const contributions = []
    const referrerRemarks = []

    const [timestamp, events, { block: { extrinsics } }] = await Promise.all([
      api.query.timestamp.now.at(blockHash),
      api.query.system.events.at(blockHash),
      api.rpc.chain.getBlock(blockHash),
    ])

    events.forEach(record => {
      const { event } = record
      if (event.section === 'crowdloan' && event.method === 'Contributed') {
        const fundIndex = event.data[1].toJSON()
        if (paraId === undefined || paraId === fundIndex) {
          // Contributed to a crowd sale. [who, fund_index, amount]
          // Contributed(AccountId, ParaId, Balance)
          contributions.push({
            who: event.data[0].toHuman(),
            fund_index: fundIndex,
            amount: amountToFloat(event.data[2])
          })
        }
      }
    })

    extrinsics.forEach(record => {
      if (record.method.section === 'utility' && record.method.method === 'batch') {
        let referrer
        try {
          const remark = record.args[0][0].args[0]
          referrer = getReferrerFromRemark({ api, remark })
        } catch (error) {
          console.warn('ignoring invlid remark', error)
        }
        if (referrer) {
          referrerRemarks.push({
            who: record._raw.signature.signer.toString(),
            referrer: referrer.toString(),
            para_id: 3000, // hard-coded in the parse function
          })
        }
      }
    })

    console.log(JSON.stringify({
      referrer_remarks: referrerRemarks,
      contributions,
      timestamp: timestamp.toNumber()
    }))
    process.exit(0)
  } catch (err) {
    console.error(err);
    process.exit(1)
  }
})();
