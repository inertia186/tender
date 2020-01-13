class ContractTreeJob < ActiveJob::Base
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  
  cattr_reader :cached_partial, :render_at
  attr_reader :controller
  
  def self.perform
    @@cached_partial = nil if !!@@render_at && @@render_at < 1.hour.ago
    
    @@cached_partial || ContractTreeJob.new.send(:render)
  end
private
  def render
    @@render_at ||= Time.now
    @@cached_partial = ''
    
    Thread.new do
      latest_transactions = Transaction.where('timestamp > ?', 24.hours.ago).where.not(contract: %w(null token))
      latest_transactions.order(:contract).distinct.pluck(:contract).each do |contract|
        template = File.read("#{Rails.root}/app/views/dashboard/_contract_tree.html.haml")
        renderer = Haml::Engine.new(template)
        @@cached_partial = renderer.render(binding, locals: {latest_transactions: latest_transactions, contract: contract})
      end
    end
    
    @@cached_partial
  end
end
