require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  # need to close console and restart guard
  #   for model to initialize carrierwave pictureuploader

  def setup
    @user = users(:kevin)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'

    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: "" }
    end

    assert_select 'div#error_explanation'

    # Valid submission and micropost appears in feed
    content = "This micropost really ties the room together"
    #fixture_file_upload(location, MIME)
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content, picture: picture }
    end
    # use @user.micropost.first.picture or
    # use assigns(:micropost) to access micropost in create action
    micropost = assigns(:micropost)
    assert micropost.picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # Deleting a post
    assert_select 'a', text: 'Delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # Visits another user
    get user_path(users(:amy))
    assert_select 'a', text: 'Delete', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts" , response.body
    other_user = users(:user_1)
    log_in_as(other_user)
    get root_path
    assert_match "#{other_user.microposts.count} microposts", response.body
    other_user.microposts.create!(content: "Loren Ipsum")
    get root_path
    assert_match "#{other_user.microposts.count} micropost", response.body
  end

end