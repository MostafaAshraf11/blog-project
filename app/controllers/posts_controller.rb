class PostsController < ApplicationController
  include Authentication
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request, except: [:index, :show]
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  # GET /posts
  def index
    posts = Post.includes(:post_tags, :comments)
    posts = posts.where("title ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    paginated = posts.page(params[:page]).per(5)

    render json: {
      current_page: paginated.current_page,
      total_pages: paginated.total_pages,
      total_count: paginated.total_count,
      posts: paginated.as_json(include: [:post_tags, :comments])
    }, status: :ok
  end

  # GET /posts/:id
  def show
    render json: @post.as_json(include: [:post_tags, :comments]), status: :ok
  end

  # GET /posts/my_posts
  def my_posts
    posts = @current_user.posts.includes(:post_tags, :comments).page(params[:page]).per(5)
    render json: {
      current_page: posts.current_page,
      total_pages: posts.total_pages,
      total_count: posts.total_count,
      posts: posts.as_json(include: [:post_tags, :comments])
    }, status: :ok
  end

  def by_author
  user = User.find_by(id: params[:author_id])
  unless user
    render json: { error: "Author not found" }, status: :not_found and return
  end

  posts = user.posts.includes(:post_tags, :comments).page(params[:page]).per(5)

  render json: {
    author: user.name,
    current_page: posts.current_page,
    total_pages: posts.total_pages,
    total_count: posts.total_count,
    posts: posts.as_json(include: [:post_tags, :comments])
  }, status: :ok
  end


  # POST /posts
  def create
    tags = params[:tags]

    unless tags.is_a?(Array) && tags.any?
      render json: { error: "At least one tag is required" }, status: :unprocessable_entity
      return
    end

    if params[:title].blank?
      render json: { error: "Title is empty" }, status: :unprocessable_entity
      return
    end

    if params[:body].blank?
      render json: { error: "Body is empty" }, status: :unprocessable_entity
      return
    end

    post = @current_user.posts.build(
      title: params[:title],
      body: params[:body],
      post_tags_attributes: tags.map { |tag| { tag: tag } }
    )

    if post.save
      DeletePostJob.set(wait: 24.hours).perform_later(post.id)
      render json: { message: "Post created", post: post }, status: :created
    else
      render json: { error: post.errors.full_messages }, status: :unprocessable_entity
    end
  end


  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      render json: { message: "Post updated", post: @post }, status: :ok
    else
      render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy
    render json: { message: "Post deleted" }, status: :ok
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
    unless @post
      render json: { error: "Post not found" }, status: :not_found
    end
  end

  def authorize_user!
    unless @post.user_id == @current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def post_params
  params.permit(:title, :body)
  end

end
