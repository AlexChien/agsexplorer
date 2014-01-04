require 'test_helper'

class ProxyControllerTest < ActionController::TestCase
  test "should get ticker" do
    get :ticker
    assert_response :success
  end

end
