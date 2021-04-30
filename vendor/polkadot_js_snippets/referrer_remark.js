#!/usr/bin/env node

const createReferrerRemark = ({ api, paraId, referrer }) => {
  const refAcc = api.createType('AccountId', referrer)
  const remark = api.createType('PhalaCrowdloanReferrerRemark', {
    magic: 'CR',
    paraId: paraId,
    referrer: refAcc,
    referrerHash: refAcc.hash.toHex()
  })
  return api.createType('Bytes', remark.toHex())
}

const createReferrerRemarkTx = ({ api, paraId, referrer }) => {
  return api.tx.system.remarkWithEvent(createReferrerRemark({ api, paraId, referrer }))
}

const getReferrerFromRemark = ({ api, remark }) => {
  const decoded = api.createType('PhalaCrowdloanReferrerRemark', remark)
  if (!decoded.magic.eq('CR')) {
    return null
  }
  const verification = decoded.referrer.hash.eq(decoded.referrerHash)
  if (verification) {
    return { paraId: decoded.paraId.toNumber(), referrer: decoded.referrer}
  }
  return null
}

exports.createReferrerRemark = createReferrerRemark
exports.createReferrerRemarkTx = createReferrerRemarkTx
exports.getReferrerFromRemark = getReferrerFromRemark
