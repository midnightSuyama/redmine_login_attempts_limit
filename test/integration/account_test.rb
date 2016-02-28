require File.expand_path('../../test_helper', __FILE__)

class AccountTest < Redmine::IntegrationTest
  fixtures :users, :email_addresses

  def setup
    Setting.plugin_redmine_login_attempts_limit[:attempts_limit] = '3'
    User.anonymous
  end
  
  def teardown
    RedmineLoginAttemptsLimit::InvalidAccounts.clear
  end
  
  def test_login
    get '/login'
    2.times { post '/login', username: 'admin', password: '' }
    post '/login', username: 'admin', password: 'admin'
    assert_equal 'admin', User.find(session[:user_id]).login
    assert_equal 0, RedmineLoginAttemptsLimit::InvalidAccounts.failed_count('admin')
  end

  def test_login_block
    get '/login'
    3.times { post '/login', username: 'admin', password: '' }
    post '/login', username: 'admin', password: 'admin'
    assert_nil session[:user_id]
    assert_template 'account/login'
  end

  def test_lost_password
    get '/login'
    3.times { post '/login', username: 'admin', password: '' }
    
    Token.delete_all
    get '/account/lost_password'
    post '/account/lost_password', mail: 'admin@somenet.foo'
    
    token = Token.first
    get '/account/lost_password', token: token.value
    post '/account/lost_password',
         token: token.value, new_password: 'newpass123', new_password_confirmation: 'newpass123'
    assert_equal 0, RedmineLoginAttemptsLimit::InvalidAccounts.failed_count('admin')
  end
end
