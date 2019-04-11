class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  scope :symbol, lambda { |symbol, options = {}|
    if !!options[:invert]
      where.not(symbol: symbol)
    else
      where(symbol: symbol)
    end
  }
  
  def self.quantity_sum
    sum("CAST(quantity AS DOUBLE)")
  end
end
