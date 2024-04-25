require "test_helper"

class MicropostsCacheTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael) # Assuming you have a user fixture or factory
    log_in_as(@user) # Helper method to simulate user login
  end

  test "cache key changes with new micropost" do
    # Assume get_user_microposts_cache_key is a helper method to generate cache key
    initial_cache_key = get_user_microposts_cache_key(@user)
    
    # Create a new micropost which should invalidate the cache
    assert_difference '@user.microposts.count', 1 do
      post microposts_path, params: { micropost: { content: "New post content" } }
    end
    
    new_cache_key = get_user_microposts_cache_key(@user)
    
    # Assert that the cache key has changed
    assert_not_equal initial_cache_key, new_cache_key, "Cache key should change with new micropost"
  end

  private

  def get_user_microposts_cache_key(user)
    "user-#{user.id}/microposts-#{user.microposts.count}-#{user.microposts.maximum(:updated_at).utc.to_s(:number)}"
  end
end
