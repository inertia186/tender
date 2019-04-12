json.transactions @transactions do |trx|
  json.block_num trx.block_num
  json.ref_steem_block_num trx.ref_steem_block_num
  json.trx_id trx.trx_id
  json.sender trx.sender
  json.contract trx.contract
  json.action trx.action
  json.payload trx.hydrated_payload.deep_transform_keys!(&:underscore)
  json.logs trx.hydrated_logs.deep_transform_keys!(&:underscore)
  json.executed_code_hash trx.executed_code_hash
  json.hash trx[:hash]
  json.database_hash trx.database_hash
  json.timestamp trx.timestamp
end

json.query do
  json.start @start
  json.elapsed @elapsed
  json.params params
end
