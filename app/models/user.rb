class User < ActiveRecord::Base
	#creates a virtual attribute(instance variable)
	attr_accessor :remember_token

	# turn into lowercase
	before_save { email.downcase! }

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


	# remembers user in database for use in persistent sessions
	def remember
		self.remember_token = User.new_token
		#bypasses validation for pass and email
		update_attribute(:remember_digest , User.digest(remember_token))
	end

	# removes token associated to user
	def forget
		update_attribute(:remember_digest, nil)
	end

	# matches with the incoming cookie's remember_token
	# returns true if token matches digest
	def authenticated?(remember_token)
		return false if remember_digest.nil? #Password.new(nil) raises error
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end

end