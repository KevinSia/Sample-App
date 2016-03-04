class Micropost < ActiveRecord::Base
  belongs_to :user

  # similiar to ORDER BY created_at DESC
  default_scope -> { order(created_at: :desc) }

  mount_uploader :picture, PictureUploader

  # validateS uses default validators/custom validator classes
  # validate  uses custom validation method/block
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 350 }
  validate :picture_size

  private

  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "must be less than 5MB")
    end
  end
end
