require "cloudinary"

class UsersController < ApplicationController
  include Authentication
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request, except: [:create, :login,:index]

  def index
    users = User.all
    render json: { users: users }, status: :ok
  end

  def profile
  render json: { user: @current_user }, status: :ok
  end

  # POST /users
  def create  
    if User.exists?(email: user_params[:email])
      render json: { error: "Email already exists" }, status: :conflict
      return
    end

    if user_params[:password].length < 6
      render json: { error: "Password must be at least 6 characters" }, status: :forbidden
      return
    end

    if user_params[:name].blank?
    render json: { error: "Name is empty" }, status: :unprocessable_entity
    return
    end

    image_url = upload_image(params[:image])
    user = User.new(user_params.merge(image: image_url))

    if user.save
      render json: { message: "User created successfully", user: user }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :internal_server_error
    end
  end

  # PUT/PATCH /users
  def update
    user = @current_user
    image_url = upload_image(params[:image]) if params[:image].present?
    update_attrs = update_user_params.to_h
    update_attrs[:image] = image_url if image_url

    if user.update(update_attrs)
      render json: { message: "User updated successfully", user: user }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :internal_server_error
    end
  end

  # DELETE /users
  def destroy
    user = @current_user

    user.destroy
    render json: { message: "User deleted successfully" }, status: :ok
  end


  # POST /users/login
  def login
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      token = JsonWebToken.encode({ id: user.id, email: user.email })
      render json: { message: "Login successful", token: token, user: user }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # POST /users/change_password
  def change_password
    user = @current_user

    unless user.authenticate(params[:old_password])
      render json: { error: "Old password is incorrect" }, status: :unauthorized
      return
    end

    if params[:new_password].blank? || params[:new_password].length < 6
      render json: { error: "New password must be at least 6 characters" }, status: :forbidden
      return
    end

    if user.update(password: params[:new_password])
      render json: { message: "Password updated successfully" }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :internal_server_error
    end
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :image, :password)
  end

  def update_user_params
    params.require(:user).permit(:name,:image)
  end

  def upload_image(image_param)
    return nil unless image_param.present?

    uploaded = Cloudinary::Uploader.upload(image_param)
    uploaded["secure_url"]
  rescue => e
    Rails.logger.error("Cloudinary upload failed: #{e.message}")
    nil
  end
end
