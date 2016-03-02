module UserRemember
  # removes token associated to user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # remembers user in database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    #bypasses validation for pass and email
    update_attribute(:remember_digest , User.digest(remember_token))
  end

end