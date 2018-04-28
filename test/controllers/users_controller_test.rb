require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    # Should not be able to open edit page when not logged in.
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should not allow the admin attribute to be edited via the web' do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: 'foobar',
                                                    password_confirmation: 'foobar',
                                                    admin: 1 } }
    assert_not @other_user.reload.admin?
  end

  test 'should redirect update when not logged in' do
    # Should not be able to directly send PATCH method when not logged in.
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect edit when not logged in as the correct user' do
    # Should not be able to open edit page when not logged in.
    # And only if logged in as the right user.
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when not logged in as the correct user' do
    # Should not be able to directly send PATCH method when not logged in.
    # And only if logged in as the right user.
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to root_url
  end
end
