class Relationship < ActiveRecord::Base

  # relationship.follower
  # relationship.followed
  # user.relationship.create
  # user.relationship.build

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
