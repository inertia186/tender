module ApplicationHelper
  def token_precision(token)
    TokensUpdatePrecision.order(timestamp: :desc).where(symbol: token.symbol).first.try(:precision) || token.precision
  end
end
