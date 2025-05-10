class CommentsController < ApplicationController
  include Authentication
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_user!, only: [:update, :destroy]

  # POST /posts/:post_id/comments
  def create
    post = Post.find_by(id: params[:post_id])
    unless post
      render json: { error: "Post not found" }, status: :not_found
      return
    end

    comment = post.comments.build(body: params[:body], user_id: @current_user.id)

    if comment.save
      render json: { message: "Comment added", comment: comment }, status: :created
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/:id
  def update
    if @comment.update(body: params[:body])
      render json: { message: "Comment updated", comment: @comment }, status: :ok
    else
      render json: { error: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    @comment.destroy
    render json: { message: "Comment deleted" }, status: :ok
  end

  private

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    unless @comment
      render json: { error: "Comment not found" }, status: :not_found
    end
  end

  def authorize_user!
    unless @comment.user_id == @current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
