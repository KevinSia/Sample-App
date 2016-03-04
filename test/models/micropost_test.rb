require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:kevin)
    # returns object in memory but doesnt modify db
    @micropost = @user.microposts.build(content: "Loream ipsum", user_id: @user.id)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "  "
    assert_not @micropost.valid?
  end

  test "content should be at most 350 characters" do
    @micropost.content = "a" * 351
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
