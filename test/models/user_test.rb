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

	test "associated microposts should be destroyed" do
		@user.save
		@user.microposts.create!(content: "Lorem Ipsum")
		assert_difference 'Micropost.count', -1 do
			@user.destroy
		end
	end

	test "should follow and unfollow a user" do
		kevin   = users(:kevin)
		michael = users(:michael)

		#relationship.yml affects this test
		assert kevin.following?(michael)

		kevin.unfollow(michael)
		assert_not kevin.following?(michael)

		kevin.follow(michael)
		assert kevin.following?(michael)
		assert michael.followers.include?(kevin)
	end

	test "feed should only followed users post" do
		kevin   = users(:kevin)
		amy			= users(:amy)
		amanda  = users(:amanda)

		# Posts from followed user
		amy.microposts.each do |following_post|
			assert kevin.feed.include?(following_post)
		end

		# Posts from self
		kevin.microposts.each do |self_post|
			assert kevin.feed.include?(self_post)
		end

		amanda.microposts.each do |unfollowing_post|
			assert_not kevin.feed.include?(unfollowing_post)
		end
	end
end
