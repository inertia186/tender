class DashboardController < TransactionsController
  caches_action :index, expires_in: 3.seconds
  
  def index
    super
  end
end
