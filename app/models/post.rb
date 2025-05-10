class Post < ApplicationRecord
  belongs_to :user
  has_many :post_tags, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, :body, presence: true
  validate :must_have_at_least_one_tag

  accepts_nested_attributes_for :post_tags

  def must_have_at_least_one_tag
    errors.add(:base, "Post must have at least one tag") if post_tags.empty?
  end
  
end