json.richlist @richlist do |balance|
  json.account balance['account']
  json.symbol balance['symbol']
  json.balance balance['balance']
  json.stake balance['stake']
  json.pending_unstake balance['pendingUnstake']
end

json.query do
  json.start @start
  json.elapsed @elapsed
  json.count @richlist.count
  json.params params
end
