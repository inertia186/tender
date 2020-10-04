module ApplicationHelper
  include Pagy::Frontend
  
  def token_precision(token)
    TokensUpdatePrecision.consensus_order(:desc).where(symbol: token.symbol).first.try(:precision) || token.precision
  end
  
  def account_active_at(account) # TODO need to invert this query again, so we can filter on contract.
    # Note, although :timestamp is more accurate here, during normal operation,
    # when everything is correctly sync'd, :created_at is approximately correct
    # and *much* faster.
    trx_account = TransactionAccount.where(account: account).order(id: :desc).first
    
    trx = Transaction.find(trx_account.trx_id)
    
    trx.created_at if !!trx
  end
  
  def symbol_active_at(symbol, kind = nil) # TODO need to invert this query again, so we can filter on contract.
    # Note, although :timestamp is more accurate here, during normal operation,
    # when everything is correctly sync'd, :created_at is approximately correct
    # and *much* faster.
    trx_symbol = TransactionSymbol.where(symbol: symbol).order(id: :desc).first
    
    trx = Transaction.find(trx_symbol.trx_id)
    
    trx.created_at if !!trx
  end
end
