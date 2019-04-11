json.transfers @transfers do |transfer|
  json.block_num transfer.trx.block_num
  json.trx_id transfer.trx_id
  json.timestamp transfer.trx.timestamp
  json.symbol transfer.symbol
  json.from transfer.trx.sender
  json.to transfer.to
  json.quantity transfer.quantity
  json.memo transfer.memo
end

json.query do
  json.start @start
  json.elapsed @elapsed
  json.count @transfers.count
  json.params params
end
