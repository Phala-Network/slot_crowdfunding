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

const { HttpProvider } = require('@polkadot/rpc-provider/http');
const { ApiPromise, WsProvider } = require('@polkadot/api');
const Decimal = require('decimal.js');
const { getReferrerFromRemark } = require('./referrer_remark');
const { typedefs } = require('./typedefs');

const d1e12 = new Decimal(10).pow(12);

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

    const finalizedHeadHash = await api.rpc.chain.getFinalizedHead()
    const finalizedHeader = await api.rpc.chain.getHeader(finalizedHeadHash)
    const finalizedHeadBlockNumber = finalizedHeader.number.toNumber()
    if (blockNumber && blockNumber > 0 && finalizedHeadBlockNumber < blockNumber) {
      console.warn(`Block #${blockNumber} not finalized yet, current ${finalizedHeadBlockNumber}`)
      return res.json({})
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
            amount: new Decimal(event.data[2].toString()).dividedBy(d1e12).toString()
          })
        }
      }
    })

    extrinsics.forEach(record => {
      const rawReferrerRemarks = []

      if (record.method.section === 'utility' && record.method.method === 'batch') {
        record.args[0].forEach(r => {
          if (r.section === 'system' && r.method === 'remarkWithEvent') {
            try {
              const remark = r.args[0]
              rawReferrerRemarks.push(getReferrerFromRemark({ api, remark }))
            } catch (error) {
              console.warn('Ignoring invalid remark', error)
            }
          }
        })
      } else if (record.method.section === 'system' && record.method.method === 'remarkWithEvent') {
        try {
          const remark = record.args[0]
          rawReferrerRemarks.push(getReferrerFromRemark({ api, remark }))
        } catch (error) {
          console.warn('Ignoring invalid remark', error)
        }
      }

      rawReferrerRemarks.forEach(rawReferrerRemark => {
        if (paraId === undefined || paraId === rawReferrerRemark.paraId) {
          referrerRemarks.push({
            who: record._raw.signature.signer.toString(),
            referrer: rawReferrerRemark.referrer.toString(),
            para_id: rawReferrerRemark.paraId,
          })
        }
      })
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
