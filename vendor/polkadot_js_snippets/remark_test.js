const { ApiPromise, WsProvider, Keyring } = require('@polkadot/api')
const { createReferrerRemark, getReferrerFromRemark } = require('./referrer_remark')
const { typedefs } = require('./typedefs')
const provider = new WsProvider('ws://127.0.0.1:9944')

;(async () => {
  const api = await ApiPromise.create({
    provider: provider,
    types: typedefs
  })

  const keyring = new Keyring({ type: 'sr25519' })

  const bob = keyring.addFromUri('//Bob')

  const remark = (await createReferrerRemark({ api, referrer: bob.address })).toHex()

  console.log({
    remark,
    decoded: await getReferrerFromRemark({ api, remark })
  })
  process.exit(0)
})()
  .catch(console.error)
  .finally(process.exit)

