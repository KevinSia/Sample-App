require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user       = users(:kevin)
    @other_user = users(:michael)
    log_in_as(@user)
    # relationship.yml
    @user.unfollow(@other_user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should follow user in html way" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, followed_id: @other_user.id
    end
  end

  test "should follow user in ajax way" do
    assert_difference "@user.following.count", 1 do
      xhr :post, relationships_path, followed_id: @other_user.id
    end
  end

  test "should unfollow user in html way" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow user in ajax way" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference "@user.following.count", -1 do
      xhr :delete, relationship_path(relationship)
    end
  end
end