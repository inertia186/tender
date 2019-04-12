json.issues @issues do |issue|
  json.block_num issue.trx.block_num
  json.trx_id issue.trx.trx_id
  json.trx_in_block issue.trx.trx_in_block
  json.timestamp issue.trx.timestamp
  json.symbol issue.symbol
  json.from issue.trx.sender
  json.to issue.to
  json.quantity issue.quantity
  json.memo issue.memo
end

json.query do
  json.start @start
  json.elapsed @elapsed
  json.count @issues.count
  json.params params
end
