require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:kevin)
  end

  test 'password resets ' do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Invalid email
    post password_resets_path, password_reset: { email: "" }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # Valid email
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form
    user = assigns(:user) # access instance variable *user* after post request

    # Invalid email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # Right email, wrong token
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url

    # Enters edit form
    # Right email & token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), email: user.email,
                                                 user: { password: "",
                                            password_confirmation: "" }
    assert_select 'div#error_explanation'

    # Empty password
    patch password_reset_path(user.reset_token), email: user.email,
                                                 user: { password: "foobar",
                                            password_confirmation: "foobars" }
    assert_select 'div#error_explanation'

    # Valid password combination
    patch password_reset_path(user.reset_token), email: user.email,
                                                 user: { password: "foobaz",
                                            password_confirmation: "foobaz" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

    test 'expired token' do
      get new_password_reset_path
      post password_resets_path, password_reset: { email: @user.email }
      @user = assigns(:user) # get model object
      @user.update_attribute(:reset_sent_at, 3.hours.ago)
    end

end