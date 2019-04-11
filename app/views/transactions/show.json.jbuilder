json.transaction do
  json.block_num @transaction.block_num
  json.ref_steem_block_num @transaction.ref_steem_block_num
  json.trx_id @transaction.trx_id
  json.sender @transaction.sender
  json.contract @transaction.contract
  json.action @transaction.action
  json.payload @transaction.hydrated_payload.deep_transform_keys!(&:underscore)
  json.logs @transaction.hydrated_logs.deep_transform_keys!(&:underscore)
  json.executed_code_hash @transaction.executed_code_hash
  json.hash @transaction[:hash]
  json.database_hash @transaction.database_hash
  json.timestamp @transaction.timestamp
end

json.query do
  json.start @start
  json.elapsed @elapsed
  json.params params
end
