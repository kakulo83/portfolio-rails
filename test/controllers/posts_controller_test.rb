require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_email = Rails.application.credentials.admin_email
    @admin_password = Rails.application.credentials.admin_password
    @post = posts(:one)
  end

  teardown do
    # Clear auth_token cookie between tests to avoid interference
    cookies.delete(:auth_token)
  end

  # Helper method to generate a valid JWT token
  def generate_valid_token(email = @admin_email)
    payload = { email: email, exp: 24.hours.from_now.to_i }
    secret_key = Rails.application.credentials.secret_key_base
    JWT.encode(payload, secret_key, "HS256")
  end

  # Helper method to set auth cookie
  def set_auth_cookie(token)
    cookies[:auth_token] = token
  end

  # Tests for index action (no authentication required)
  test "should get index without authentication" do
    get posts_url, as: :json
    assert_response :success
  end

  # Tests for pagination (Goal 3.8)
  test "should paginate posts in index" do
    # Create multiple posts
    10.times { |i| Post.create!(title: "Post #{i}") }
    
    # Make sure no auth cookie is set
    cookies.delete(:auth_token)
    
    get posts_url(page: 1, per_page: 5), as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["posts"].present?
    assert json_response["pagination"].present?
    assert_equal 1, json_response["pagination"]["current_page"]
    assert_equal 5, json_response["pagination"]["per_page"]
    assert_equal 5, json_response["posts"].length
    assert json_response["pagination"]["total_pages"] >= 2
    assert json_response["pagination"]["total_count"] >= 10
  end

  test "should return second page of posts" do
    # Create multiple posts
    10.times { |i| Post.create!(title: "Post #{i}") }
    
    # Make sure no auth cookie is set
    cookies.delete(:auth_token)
    
    get posts_url(page: 2, per_page: 5), as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["pagination"]["current_page"]
  end

  test "should use default pagination values when not specified" do
    get posts_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["pagination"]["current_page"]
    assert_equal 10, json_response["pagination"]["per_page"]
  end

  # Tests for Goal 3.9 - index should not include Content data
  test "should not include content data in index" do
    # Create a post with content
    post_with_content = Post.create!(title: "Post with Content")
    post_with_content.contents.create!(order: 1, body: "Content body", type: "text")
    
    get posts_url, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    posts_data = json_response["posts"]
    
    # Check that contents are not included
    posts_data.each do |post|
      assert_nil post["contents"], "Index should not include contents"
    end
  end

  # Tests for show action (no authentication required)
  test "should show post without authentication" do
    get post_url(@post), as: :json
    assert_response :success
  end

  # Tests for Goal 4.0 - show should include ordered Content data
  test "should include content data in show" do
    # Create a post with multiple contents
    post_with_content = Post.create!(title: "Post with Content")
    content1 = post_with_content.contents.create!(order: 2, body: "Second content", type: "text")
    content2 = post_with_content.contents.create!(order: 1, body: "First content", type: "image")
    content3 = post_with_content.contents.create!(order: 3, body: "Third content", type: "text")
    
    get post_url(post_with_content), as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    # Check that contents are included
    assert json_response["contents"].present?, "Show should include contents"
    assert_equal 3, json_response["contents"].length
    
    # Check that contents are ordered by the order attribute
    assert_equal 1, json_response["contents"][0]["order"]
    assert_equal "First content", json_response["contents"][0]["body"]
    assert_equal 2, json_response["contents"][1]["order"]
    assert_equal "Second content", json_response["contents"][1]["body"]
    assert_equal 3, json_response["contents"][2]["order"]
    assert_equal "Third content", json_response["contents"][2]["body"]
  end

  # Tests for create action - requires authentication
  test "should create post with valid auth cookie" do
    token = generate_valid_token
    set_auth_cookie(token)
    
    assert_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post" } }, as: :json
    end
    
    assert_response :created
  end

  test "should return 403 when creating post without auth cookie" do
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post" } }, as: :json
    end
    
    assert_response :forbidden
  end

  test "should return 403 when creating post with invalid JWT token" do
    set_auth_cookie("invalid.token.here")
    
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post" } }, as: :json
    end
    
    assert_response :forbidden
  end

  test "should return 403 when creating post with JWT containing wrong email" do
    token = generate_valid_token("wrong@example.com")
    set_auth_cookie(token)
    
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post" } }, as: :json
    end
    
    assert_response :forbidden
  end

  test "should return 403 when creating post with expired JWT token" do
    payload = { email: @admin_email, exp: 1.hour.ago.to_i }
    secret_key = Rails.application.credentials.secret_key_base
    expired_token = JWT.encode(payload, secret_key, "HS256")
    set_auth_cookie(expired_token)
    
    assert_no_difference("Post.count") do
      post posts_url, params: { post: { title: "New Post" } }, as: :json
    end
    
    assert_response :forbidden
  end

  # Tests for update action - requires authentication
  test "should update post with valid auth cookie" do
    token = generate_valid_token
    set_auth_cookie(token)
    
    patch post_url(@post), params: { post: { title: "Updated Title" } }, as: :json
    
    assert_response :success
    @post.reload
    assert_equal "Updated Title", @post.title
  end

  test "should return 403 when updating post without auth cookie" do
    original_title = @post.title
    
    patch post_url(@post), params: { post: { title: "Updated Title" } }, as: :json
    
    assert_response :forbidden
    @post.reload
    assert_equal original_title, @post.title
  end

  test "should return 403 when updating post with invalid JWT token" do
    set_auth_cookie("invalid.token.here")
    original_title = @post.title
    
    patch post_url(@post), params: { post: { title: "Updated Title" } }, as: :json
    
    assert_response :forbidden
    @post.reload
    assert_equal original_title, @post.title
  end

  test "should return 403 when updating post with JWT containing wrong email" do
    token = generate_valid_token("wrong@example.com")
    set_auth_cookie(token)
    original_title = @post.title
    
    patch post_url(@post), params: { post: { title: "Updated Title" } }, as: :json
    
    assert_response :forbidden
    @post.reload
    assert_equal original_title, @post.title
  end

  # Tests for destroy action - requires authentication
  test "should destroy post with valid auth cookie" do
    token = generate_valid_token
    set_auth_cookie(token)
    
    assert_difference("Post.count", -1) do
      delete post_url(@post), as: :json
    end
    
    assert_response :no_content
  end

  # Tests for Goal 4.1 - deleting Post should cascade delete Content records
  test "should delete associated contents when deleting post" do
    # Create a post with contents
    post_with_content = Post.create!(title: "Post to delete")
    content1 = post_with_content.contents.create!(order: 1, body: "Content 1", type: "text")
    content2 = post_with_content.contents.create!(order: 2, body: "Content 2", type: "text")
    
    content_ids = [content1.id, content2.id]
    
    token = generate_valid_token
    set_auth_cookie(token)
    
    assert_difference("Post.count", -1) do
      assert_difference("Content.count", -2) do
        delete post_url(post_with_content), as: :json
      end
    end
    
    assert_response :no_content
    
    # Verify contents are actually deleted
    content_ids.each do |content_id|
      assert_nil Content.find_by(id: content_id), "Content should be deleted"
    end
  end

  test "should return 403 when destroying post without auth cookie" do
    assert_no_difference("Post.count") do
      delete post_url(@post), as: :json
    end
    
    assert_response :forbidden
  end

  test "should return 403 when destroying post with invalid JWT token" do
    set_auth_cookie("invalid.token.here")
    
    assert_no_difference("Post.count") do
      delete post_url(@post), as: :json
    end
    
    assert_response :forbidden
  end

  test "should return 403 when destroying post with JWT containing wrong email" do
    token = generate_valid_token("wrong@example.com")
    set_auth_cookie(token)
    
    assert_no_difference("Post.count") do
      delete post_url(@post), as: :json
    end
    
    assert_response :forbidden
  end
end
