module ApplicationHelper
  include Pagy::Frontend
  
  def token_precision(token)
    TokensUpdatePrecision.consensus_order(:desc).where(symbol: token.symbol).first.try(:precision) || token.precision
  end
  
  def symbol_active_at(symbol)
    # Note, although :timestamp is more accurate here, during normal operation,
    # when everything is correctly sync'd, :created_at is approximately correct
    # and *much* faster.
    trx_symbol = TransactionSymbol.where(symbol: symbol).order(id: :desc).first
    
    trx = Transaction.find(trx_symbol.trx_id)
    
    trx.created_at if !!trx
  end
end
