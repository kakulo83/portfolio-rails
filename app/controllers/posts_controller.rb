class PostsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :update, :destroy, :get_presigned_url ]
  before_action :set_post, only: [ :show, :update, :destroy ]

  # GET /posts
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    @posts = Post.page(page).per(per_page)

    render json: {
      posts: @posts,
      pagination: {
        current_page: @posts.current_page,
        total_pages: @posts.total_pages,
        total_count: @posts.total_count,
        per_page: @posts.limit_value
      }
    }
  end

  # GET /posts/:id
  def show
    content_hash = JSON.parse(@post.content.gsub("=>", ":"))

    render json: {
             id: @post.id,
             title: @post.title,
             content: content_hash,
             created_at: @post.created_at
           }
  end

  # POST /posts
  def create
    @post = Post.new(post_params)

    if @post.save
      render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy
    head :no_content
  end

  def get_presigned_url
    key = params[:key]
    uploader = Uploader.new
    presigned = uploader.get_url(key)
    render json: {
             presigned_url: presigned.url
           }
  end

  private

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Post not found" }, status: :not_found
  end

  def post_params
    params.expect(post: [ :title, content: {} ])
  end
end
