const { ApiPromise, WsProvider, Keyring } = require('@polkadot/api')
const { createReferrerRemark, getReferrerFromRemark } = require('./referrer_remark')

const provider = new WsProvider('ws://127.0.0.1:9944')

;(async () => {
  const api = await ApiPromise.create({
    provider: provider,
    types: {
      "PhalaCrowdloanReferrerRemark": {
        "magic": "Bytes",
        "paraId": "ParaId",
        "referrer": "AccountId",
        "referrerSingnature": "Signature"
      }
    }
  })

  const keyring = new Keyring({ type: 'sr25519' })

  const alice = keyring.addFromUri('//Alice')
  const bob = keyring.addFromUri('//Bob')

  const remark = (await createReferrerRemark({ api, signer: alice, referrer: bob.address })).toHex()

  console.log({
    remark,
    decoded: await getReferrerFromRemark({ api, signer: alice, remark })
  })
  process.exit(0)
})()
  .catch(console.error)
  .finally(process.exit)

