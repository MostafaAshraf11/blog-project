require 'rails_helper'

RSpec.describe "Posts API", type: :request do
  let(:user_params) do
    {
      user: {
        name: "Test User",
        email: "testposter@example.com",
        password: "secure123"
      }
    }
  end

  let(:login_params) do
    {
      email: "testposter@example.com",
      password: "secure123"
    }
  end

  let(:valid_post_params) do
    {
      title: "Test Post",
      body: "This is a test post body.",
      tags: ["ruby", "rails"]
    }
  end

  let(:headers) do
    {
      "Authorization" => "Bearer #{token}"
    }
  end

  let(:token) do
    post "/users", params: user_params
    post "/users/login", params: login_params
    JSON.parse(response.body)["token"]
  end

  let(:post_id) do
    post "/posts", params: valid_post_params, headers: headers
    JSON.parse(response.body).dig("post", "id")
  end

  before do
    allow(DeletePostJob).to receive(:set).and_return(DeletePostJob)
    allow(DeletePostJob).to receive(:perform_later)
  end

  describe "POST /posts" do
    context "with valid params and token" do
      it "creates a post" do
        post "/posts", params: valid_post_params, headers: headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("message" => "Post created")
      end
    end

    context "without token" do
      it "rejects the request" do
        post "/posts", params: valid_post_params
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid or missing token")
      end
    end

    context "with missing title" do
      it "returns error" do
        post "/posts", params: valid_post_params.merge(title: ""), headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Title is empty")
      end
    end

    context "with missing body" do
      it "returns error" do
        post "/posts", params: valid_post_params.merge(body: ""), headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Body is empty")
      end
    end

    context "with no tags" do
      it "returns error" do
        post "/posts", params: valid_post_params.except(:tags), headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "At least one tag is required")
      end
    end
  end

  describe "Comments API" do
    let(:comment_params) { { body: "test comment" } }
    let(:post_url) { "/posts/#{post_id}/comments" }

    before do
      post post_url, params: comment_params, headers: headers
      @comment_id = JSON.parse(response.body).dig("comment", "id")
    end

    it "creates a comment" do
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include("message" => "Comment added")
    end
  end
end
