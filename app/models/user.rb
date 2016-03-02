class User < ActiveRecord::Base

  # lib/user_*.rb
  include UserFollow
  include UserActivation
  include UserPasswordReset
  include UserRemember
  # ------ associations ------
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
  # user.followers -> follower_id array
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  # ------ attributes ------
	#creates a virtual attribute(instance variable)
	attr_accessor :remember_token, :activation_token, :reset_token

  # ------ callbacks ------
	# turn into lowercase
	before_save :downcase_email
	before_create :create_activation_digest

  # ------ validations ------
	validates :name ,  presence: true , length: { maximum: 50 }
	validates :email , presence: true , length: { maximum: 255 },
                                       email: true,
                                  uniqueness: { case_sensitive: false }
	validates :password , presence: true , length: { minimum: 6 }, allow_nil: true

	# to produce attributes: password & password_confirmation
	# it will also validate nil password
	has_secure_password

  # ------ filterrific ------
  filterrific(
  default_filter_params: { sorted_by: 'created_at_desc'},
  available_filters: [
    :sorted_by,
    :search_query,
    :with_created_at_gte
    ]
  )

  # ------ scopes ------
  # filterrific scopes
  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      # Simple sort on the created_at column.
      # Make sure to include the table name to avoid ambiguous column names.
      # Joining on other tables is quite common in Filterrific, and almost
      # every ActiveRecord table has a 'created_at' column.
      order("users.created_at #{ direction }")
    when /^name_/
      # Simple sort on the name colums
      order("LOWER(users.name) #{ direction }") #, LOWER(users.first_name) #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # always include the lower boundary for semi open intervals
  scope :with_created_at_gte, lambda { |reference_time|
    where('users.created_at >= ?', reference_time)
  }

  scope :search_query, lambda { |query|
    # Matches using LIKE, automatically appends '%' to each term.
    # LIKE is case INsensitive with MySQL, however it is case
    # sensitive with PostGreSQL. To make it work in both worlds,
    # we downcase everything.
    return nil if query.blank?

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)

    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    num_or_conds = 1

    where(
      terms.map { |term|
        "(LOWER(users.name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }


  # ------ class methods ------
	class << self
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end

    # returns a random token
    def new_token
      SecureRandom.urlsafe_base64
    end

    # -- filterrific methods --
    def options_for_sorted_by
      [
        ['Name (a-z)', 'name_asc'],
        ['Registration date (newest first)', 'created_at_desc'],
        ['Registration date (oldest first)', 'created_at_asc'],
      ]
    end
  end

  # ------ instance methods --------


  # matches with the incoming token
  # returns true if token matches digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil? # Password.new(nil) raises error
    BCrypt::Password.new(digest).is_password?(token)
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    # use includes to avoid N+1 by eager loading users
    Micropost.includes(:user).where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end


  # -- filterrific methods --
  def decorated_created_at
    created_at.to_date.to_s(:long)
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