class DeletePostJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    post.destroy if post.present?
  end
end