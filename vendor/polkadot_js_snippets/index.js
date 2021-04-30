#!/usr/bin/env node

const { HttpProvider } = require('@polkadot/rpc-provider/http');
const { ApiPromise, WsProvider } = require('@polkadot/api');
const { getReferrerFromRemark } = require('./referrer_remark');
const { typedefs } = require('./typedefs');
const Decimal = require('decimal.js');

const d1e12 = new Decimal(10).pow(12);

const express = require('express');
const app = express();

app.use(express.json())

const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')

const argv = yargs(hideBin(process.argv))
  .option('port', {
    type: 'integer'
  })
  .option('para-id', {
    alias: 'id',
    type: 'integer'
  })
  .option('endpoint')
  .demandOption(['port', 'endpoint'])
  .argv

require('dotenv').config();

const paraId = argv["para-id"]

let provider = null;
let api = null;
let finalizedHeadBlockNumberOnStart = 0;

(async () => {
  const endpoint = argv["endpoint"]

  if (endpoint.startsWith('wss://') || endpoint.startsWith('ws://')) {
    provider = new WsProvider(endpoint)
  } else if (endpoint.startsWith('https://') || endpoint.startsWith('http://')) {
    provider = new HttpProvider(endpoint)
  } else {
    console.warn(`Invalid endpoint ${endpoint}`)
    process.exit(1)
  }

  api = await ApiPromise.create({
    provider: provider,
    types: typedefs
  })

  const finalizedHeadHashOnStart = await api.rpc.chain.getFinalizedHead()
  const finalizedHeaderOnStart = await api.rpc.chain.getHeader(finalizedHeadHashOnStart)
  finalizedHeadBlockNumberOnStart = finalizedHeaderOnStart.number.toNumber()
  console.log(`Current finalized block number ${finalizedHeadBlockNumberOnStart}`)
})()

app.get('/fetch_block/:id', async (req, res) => {
  const blockNumber = req.params.id

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
    return res.json({})
  }

  if (blockNumber && blockNumber > finalizedHeadBlockNumberOnStart) {
    const finalizedHeadHash = await api.rpc.chain.getFinalizedHead()
    const finalizedHeader = await api.rpc.chain.getHeader(finalizedHeadHash)
    const finalizedHeadBlockNumber = finalizedHeader.number.toNumber()
    if (finalizedHeadBlockNumber < blockNumber) {
      console.warn(`Block #${blockNumber} not finalized yet, current ${finalizedHeadBlockNumber}`)
      return res.json({})
    }
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
        try {
          referrerRemarks.push({
            who: record._raw.signature.signer.toString(),
            referrer: rawReferrerRemark.referrer.toString(),
            para_id: rawReferrerRemark.paraId,
          })
        } catch (error) {
          console.warn('Ignoring invalid remark', error)
        }
      }
    })
  })

  try {
    return res.json({
      referrer_remarks: referrerRemarks,
      contributions,
      timestamp: timestamp.toNumber()
    })
  } catch (error) {
    return res.json({});
  }
})

app.get('/fund_infos', async (req, res) => {
  console.log(req.query)
  const blockNumber = req.query.block_number

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
      deposit: new Decimal(jsonValue.deposit.toString()).dividedBy(d1e12).toString(),
      raised: new Decimal(jsonValue.raised.toString()).dividedBy(d1e12).toString(),
      cap: new Decimal(jsonValue.cap.toString()).dividedBy(d1e12).toString(),
      end: jsonValue.end,
      depositor: jsonValue.depositor
    }

    // console.log(jsonValue)
    // console.log(fundInfos[k.toHuman()[0]])
  }

  // console.log(fundInfos)
  try {
    return res.json(fundInfos)
  } catch (error) {
    return res.json({});
  }
})

app.listen(argv["port"], () => {
  console.log("Server started");
});
