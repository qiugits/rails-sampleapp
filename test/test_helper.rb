require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # app/helpers/application_helper.rbで定義したものを使えるようにする
  include ApplicationHelper

  def is_logged_in?
    !session[:user_id].nil?
  end

  # log in as test user
  def log_in_as(user)
    session[:user_id] = user.id
  end

  class ActionDispatch::IntegrationTest  # test/integration/users_login_test.rbの継承元クラス

    def log_in_as(user, password: 'password', remember_me: '1')
      post login_path, params: { session: { email: user.email,
                                            password: password,
                                            remember_me: remember_me } }
    end
  end
end
