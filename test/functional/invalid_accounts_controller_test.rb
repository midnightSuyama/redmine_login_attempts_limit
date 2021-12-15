require File.expand_path('../../test_helper', __FILE__)

class InvalidAccountsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    User.current = nil
  end
  
  def test_clear
    post :clear, xhr: true
    assert_response :unauthorized

    @request.session[:user_id] = 1
    post :clear, xhr: true
    assert_response :success

    @request.session[:user_id] = 2
    post :clear, xhr: true
    assert_response :forbidden
  end
end
