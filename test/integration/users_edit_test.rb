require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:kevin)
  end

  test 'unsuccessful edits' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name: "",
                                    email: "foo@invalid",
                                    password: "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end

  test 'successful edits with friendly forwarding' do
    get edit_user_path(@user)
    assert_equal session[:forwarding_url], request.url
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    assert session[:forwarding_url].nil?
    name = "sia"
    email = "sia@example.com"  # edited params
    patch user_path(@user), user: { name: name,
                                   email: email,
                                   password: "",
                                   password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload # IMPORTANT else @user.name will still be same as in fixtures
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
