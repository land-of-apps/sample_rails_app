require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
      # Setup a variable for the initial cache key
    initial_cache_key = @user.microposts_cache_key(page_number: 1, page_size: 30)

    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # Correct pagination link
    
    # Valid submission
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    
    # Validate cache key has changed after a new micropost is created
    new_cache_key = @user.microposts_cache_key(page_number: 1, page_size: 30)
    assert_not_equal initial_cache_key, new_cache_key, "Cache key should not match after micropost creation"
    
    # Delete post.
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    
    # Visit different user (no delete links).
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end
