require File.expand_path('../../test_helper', __FILE__)

class InvalidAccountsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    User.current = nil
  end
  
  def test_clear
    xhr :post, :clear
    assert_response :unauthorized

    @request.session[:user_id] = 1
    xhr :post, :clear
    assert_response :success

    @request.session[:user_id] = 2
    xhr :post, :clear
    assert_response :forbidden
  end
end
