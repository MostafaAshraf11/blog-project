require 'rails_helper'

RSpec.describe "Users API", type: :request do
  # Valid user parameters for the tests
  let(:valid_user_params) do
    {
      user: {
        name: "Test User",
        email: "test123@example.com",
        password: "secure123"
      }
    }
  end

  # Invalid user parameters to test various edge cases
  let(:invalid_user_params) do
    {
      user: {
        name: "",
        email: "bademail",
        password: "123"
      }
    }
  end

  describe "POST /users" do
    context "with valid params" do
      it "creates a user and returns status :created" do
        post "/users", params: valid_user_params
        expect(response).to have_http_status(:created) # 201 status
        expect(JSON.parse(response.body)).to include("message" => "User created successfully")
      end
    end

    context "with invalid params" do
      it "rejects missing name" do
        post "/users", params: { user: valid_user_params[:user].merge(name: "") }
        expect(response).to have_http_status(:unprocessable_entity) # 422 status
        expect(JSON.parse(response.body)).to include("error" => "Name is empty")
      end

      it "rejects short password" do
        post "/users", params: { user: valid_user_params[:user].merge(password: "123") }
        expect(response).to have_http_status(:forbidden) # 403 status for forbidden
        expect(JSON.parse(response.body)).to include("error" => "Password must be at least 6 characters")
      end

      it "rejects duplicate email" do
        post "/users", params: valid_user_params
        post "/users", params: valid_user_params # Trying to create the same user again
        expect(response).to have_http_status(:conflict) # 409 status for conflict
        expect(JSON.parse(response.body)).to include("error" => "Email already exists")
      end
    end
  end

  describe "POST /users/login" do
    # Setup: Create a user before testing login
    let!(:user) { User.create!(valid_user_params[:user]) }

    it "authenticates with correct credentials" do
      post "/users/login", params: { email: user.email, password: "secure123" }
      expect(response).to have_http_status(:ok) # 200 status
      expect(JSON.parse(response.body)).to include("token")
    end

    it "rejects incorrect password" do
      post "/users/login", params: { email: user.email, password: "wrongpass" }
      expect(response).to have_http_status(:unauthorized) # 401 status for unauthorized
      expect(JSON.parse(response.body)).to include("error" => "Invalid email or password")
    end
  end

  describe "GET /users/profile" do
    # Setup: Create a user and login to retrieve a token
    let!(:user) { User.create!(valid_user_params[:user]) }
    let(:token) do
      post "/users/login", params: { email: user.email, password: "secure123" }
      JSON.parse(response.body)["token"]
    end

    it "returns the current user profile" do
      get "/users/profile", headers: { Authorization: "Bearer #{token}" }
      expect(response).to have_http_status(:ok) # 200 status
      expect(JSON.parse(response.body)).to have_key("user") # The response should contain user data
    end

    it "rejects request without token" do
      get "/users/profile"
      expect(response).to have_http_status(:unauthorized) # 401 status for unauthorized access
      expect(JSON.parse(response.body)).to include("error" => "Invalid or missing token")
    end
  end
end
