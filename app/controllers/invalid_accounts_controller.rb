class InvalidAccountsController < ApplicationController

  before_action :require_admin
  
  def clear
    RedmineLoginAttemptsLimit::InvalidAccounts.clear
    head :ok
  end
end
