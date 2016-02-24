class User < ActiveRecord::Base

	has_many :microposts, dependent: :destroy
  # active -> you are the follower  -> your id = follower_id
  # passive -> someone followed you -> your id = followed_id
  has_many :active_relationships,  class_name: "Relationship",
                                  foreign_key: "follower_id",
                                    dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                    dependent: :destroy
  # user.following -> followed_id array
  # user.followers -> followers_id array
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

	#creates a virtual attribute(instance variable)
	attr_accessor :remember_token, :activation_token, :reset_token

	# turn into lowercase
	before_save :downcase_email
	before_create :create_activation_digest

	validates :name ,  presence: true , length: { maximum: 50 }
	validates :email , presence: true , length: { maximum: 255 },
                                       email: true,
                                  uniqueness: { case_sensitive: false }
	validates :password , presence: true , length: { minimum: 6 }, allow_nil: true

	# to produce virtual columns: password & password_confirmation
	# it will also validate nil password
	has_secure_password

	class << self
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end

		# returns a random token
		def new_token
			SecureRandom.urlsafe_base64
		end
	end


	def activate
		update_columns(activated: true, activated_at: Time.zone.now)
	end

	# matches with the incoming cookie's remember_token
	# returns true if token matches digest
	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil? # Password.new(nil) raises error
		BCrypt::Password.new(digest).is_password?(token)
	end

	def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def feed
  	Micropost.includes(:user).where("user_id = ?", id)
  end

	# removes token associated to user
	def forget
		update_attribute(:remember_digest, nil)
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	# remembers user in database for use in persistent sessions
	def remember
		self.remember_token = User.new_token
		#bypasses validation for pass and email
		update_attribute(:remember_digest , User.digest(remember_token))
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

  def following?(other_user)
    following.include?(other_user)
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end



  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end