require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # In case email is invalid
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Email is valid
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Test the reset form
    user = assigns(:user)
    # In case email is invalid
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # In case user is invalid
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # In case token is invalid while email is valid
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Both email and token are valid
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                user: { password: "foobaz",
                        password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # In case password is ""
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                user: { password: "",
                        password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # Valid password and password_confirmation
    patch password_reset_path(user.reset_token),
      params: { email: user.email,
                user: { password: "foobaz",
                        password_confirmation: "foobaz" } }
    assert_nil user.reload.reset_digest
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
      params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
      params: { email: @user.email, 
                user: { password: "foobar",
                        password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match "expired", response.body
  end
end
