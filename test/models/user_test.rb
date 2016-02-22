require 'test_helper'

class UserTest < ActiveSupport::TestCase

	def setup
		@user = User.new(name: "Example User" , email: "user@example.com" ,
							password: "foobar" , password_confirmation: "foobar")
	end

	test "should be valid" do
		assert @user.valid?
	end

	#assert_not passes if statement is false
	test "name should be present" do
		@user.name = "  "
		assert_not @user.valid?
	end

	test "email should be present" do
		@user.email = "  "
		assert_not @user.valid?
	end

	test "name should not be too long" do
		@user.name = "a" * 51
		assert_not @user.valid?
	end

	test "email should not be too long" do
		@user.email = 'a' * 244 + '@example.com'
		assert_not @user.valid?
	end

	test "email validation should accept valid addresses" do
		valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]

		valid_addresses.each do |address|
			@user.email = address
			assert @user.valid? ,     "#{address.inspect} should be valid" #show error message
		end
	end

	test "email validation should reject invalid addresses" do
		invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.org foo@bar+baz.com
											foo@bar..org]

		invalid_addresses.each do |address|
			@user.email = address
			assert_not @user.valid? , "#{address.inspect} should be invalid"

		end
	end

	#check uniqueness , upcase & lowcase should treated as one
	test "email addresses should be unique" do
		duplicate_user = @user.dup
		duplicate_user.email = @user.email.upcase #to check if upcase = lowcase
		@user.save
		assert_not duplicate_user.valid?
	end

	test "password should be present" do
		@user.password = @user.password_confirmation = " " * 6
		assert_not @user.valid?
	end

	test "password should have minimum length" do
		@user.password = @user.password_confirmation = "a" * 5
		assert_not @user.valid?
	end

	test "email should be down-cased" do
		mixed_cased_email = "FoO@ExamPle.coM"
		@user.email = mixed_cased_email
		@user.save
		assert_equal mixed_cased_email.downcase , @user.reload.email
	end

	#remember_digest is already nil, remember_token can be anything
	test "authenticated? return false if received nil digest" do
		assert_not @user.authenticated?(:remember, "abc")
	end
end
