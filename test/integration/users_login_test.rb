require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

	#users corresponds to fixtures
	def setup
		@user = users(:kevin)
	end
  
	test 'login with invalid information' do
		get login_path
		assert_template 'sessions/new'
		post login_path, session: {email: "" , password: ""}
		assert_template 'sessions/new'
		assert_not flash.empty?
		get root_path
		assert flash.empty? , "Flash message appears"
	end

	test 'login with valid information' do
		get login_path
		post login_path , session: {email: @user.email , password: 'password'}
		assert_redirected_to @user   	#check redirect path
		follow_redirect!				#redirect to path
		assert_template 'users/show'
		assert_select "a[href=?]" , login_path , count = 0
		assert_select "a[href=?]" , logout_path
		assert_select "a[href=?]" , user_path(@user)

	end
end
