module ApplicationHelper
  def token_precision(token)
    TokensUpdatePrecision.order(block_num: :desc).where(symbol: token.symbol).first.try(:precision) || token.precision
  end
end
