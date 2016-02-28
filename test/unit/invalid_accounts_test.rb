require File.expand_path('../../test_helper', __FILE__)

module RedmineLoginAttemptsLimit
  module InvalidAccounts
    mattr_accessor :status
  end
end

class InvalidAccountsTest < ActiveSupport::TestCase
  include RedmineLoginAttemptsLimit

  def setup
    Setting.plugin_redmine_login_attempts_limit[:attempts_limit] = '3'
    Setting.plugin_redmine_login_attempts_limit[:block_minutes]  = '60'
  end
  
  def teardown
    InvalidAccounts.clear
  end

  def test_update
    InvalidAccounts.update('admin')
    assert_equal 1, InvalidAccounts.status[:admin][:failed_count]
    assert_kind_of Time, InvalidAccounts.status[:admin][:updated_at]

    InvalidAccounts.update('admin')
    assert_equal 2, InvalidAccounts.status[:admin][:failed_count]
  end
  
  def test_failed_count
    InvalidAccounts.update('admin')
    assert_equal 1, InvalidAccounts.failed_count('admin')
    assert_equal 0, InvalidAccounts.failed_count('user')
  end

  def test_attempts_limit
    Setting.plugin_redmine_login_attempts_limit[:attempts_limit] = '10'
    assert_equal 10, InvalidAccounts.attempts_limit
    
    Setting.plugin_redmine_login_attempts_limit[:attempts_limit] = '0'
    assert_equal 1, InvalidAccounts.attempts_limit
  end

  def test_blocked?
    3.times { InvalidAccounts.update('user') }
    assert InvalidAccounts.blocked?('user')

    2.times { InvalidAccounts.update('admin') }
    assert_not InvalidAccounts.blocked?('admin')
  end

  def test_clear
    InvalidAccounts.update('user1')
    InvalidAccounts.update('user2')
    InvalidAccounts.update('user3')
    
    InvalidAccounts.clear('user2')
    assert_not InvalidAccounts.status.key?(:user2)
    assert_equal 2, InvalidAccounts.status.count

    InvalidAccounts.clear
    assert_empty InvalidAccounts.status
  end

  def test_clean_expired
    InvalidAccounts.update('user1')
    InvalidAccounts.update('user2')
    InvalidAccounts.update('user3')

    InvalidAccounts.status[:user2][:updated_at] -= (60*60)+1
    InvalidAccounts.clean_expired
    assert_not InvalidAccounts.status.key?(:user2)
    assert_equal 2, InvalidAccounts.status.count
  end
end
