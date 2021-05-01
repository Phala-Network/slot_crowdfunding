#!/usr/bin/env node
const createReferrerRemark = ({ api, referrer }) => {
  const refAcc = api.createType('AccountId', referrer)
  const remark = api.createType('PhalaCrowdloanReferrerRemark', {
    magic: 'CR',
    paraId: 3000,
    referrer: refAcc,
    referrerHash: refAcc.hash.toHex()
  })
  return api.createType('Bytes', remark.toHex())
}

const createReferrerRemarkTx = ({ api, referrer }) => {
  return api.tx.system.remarkWithEvent(createReferrerRemark({ api, referrer }))
}

const getReferrerFromRemark = ({ api, remark }) => {
  const decoded = api.createType('PhalaCrowdloanReferrerRemark', remark)
  if (!(decoded.paraId.eq(3000) && decoded.magic.eq('CR'))) {
    return null
  }
  const verification = decoded.referrer.hash.eq(decoded.referrerHash)
  if (verification) {
    return decoded.referrer
  }
  return null
}

exports.createReferrerRemark = createReferrerRemark
exports.createReferrerRemarkTx = createReferrerRemarkTx
exports.getReferrerFromRemark = getReferrerFromRemark
