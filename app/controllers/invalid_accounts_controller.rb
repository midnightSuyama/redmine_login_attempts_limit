class InvalidAccountsController < ApplicationController
  unloadable

  before_filter :require_admin
  
  def clear
    RedmineLoginAttemptsLimit::InvalidAccounts.clear
    head :ok
  end
end
