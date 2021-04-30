#!/usr/bin/env node
const { cryptoWaitReady, decodeAddress, signatureVerify } = require('@polkadot/util-crypto')

const createReferrerRemark = async ({ api, signer, referrer }) => {
  await cryptoWaitReady()

  const refAcc = api.createType('AccountId', referrer)
  const remark = api.createType('PhalaCrowdloanReferrerRemark', {
    magic: 'CR',
    paraId: 3000,
    referrer: refAcc,
    referrerSingnature: signer.sign(refAcc.toHex())
  })
  return api.createType('Bytes', remark.toHex())
}

const createReferrerRemarkTx = async ({ api, signer, referrer }) => {
  return api.tx.system.remarkWithEvent(await createReferrerRemark({ api, signer, referrer }))
}

const getReferrerFromRemark = async ({ api, signer, remark }) => {
  await cryptoWaitReady()
  const decoded = api.createType('PhalaCrowdloanReferrerRemark', remark)
  if (!(decoded.paraId.eq(3000) && decoded.magic.eq('CR'))) {
    return null
  }
  const verification = signatureVerify(decoded.referrer, decoded.referrerSingnature, signer.address)
  if (verification.isValid) {
    return decoded.referrer
  }
  return null
}

exports.createReferrerRemark = createReferrerRemark
exports.createReferrerRemarkTx = createReferrerRemarkTx
exports.getReferrerFromRemark = getReferrerFromRemark
