module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:id]
      @current_user = User.find_by(id: decoded[:id], email: decoded[:email])
      render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
    else
      render json: { error: "Invalid or missing token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
