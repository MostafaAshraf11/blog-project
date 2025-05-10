class TagsController < ApplicationController
  include Authentication
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request
  before_action :set_post, only: [:create]
  before_action :set_post_tag, only: [:update, :destroy]
  before_action :authorize_user!, only: [:create, :update, :destroy]

  def create
    tag = @post.post_tags.build(tag: params[:tag])
    if tag.save
      render json: { message: "Tag added", tag: tag }, status: :created
    else
      render json: { error: tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post_tag.update(tag: params[:tag])
      render json: { message: "Tag updated", tag: @post_tag }, status: :ok
    else
      render json: { error: @post_tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    post = @post_tag.post
    if post.post_tags.count <= 1
      render json: { error: "Post must have at least one tag" }, status: :unprocessable_entity
      return
    end

    @post_tag.destroy
    render json: { message: "Tag removed" }, status: :ok
  end

  private

  def set_post
    @post = Post.find_by(id: params[:post_id])
    render json: { error: "Post not found" }, status: :not_found unless @post
  end

  def set_post_tag
    @post_tag = PostTag.find_by(id: params[:id])
    render json: { error: "Tag not found" }, status: :not_found unless @post_tag
  end

  def authorize_user!
    post = @post || @post_tag&.post
    unless post&.user_id == @current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
