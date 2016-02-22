require 'rails_helper'

RSpec.describe User, type: :model do

  
  describe "validate name" do
  	it { should validate_presence_of(:name) }
  	it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end

  describe "validate email" do
  	it { should validate_presence_of(:email) }
  	it { should validate_length_of(:email).is_at_most(255) }
  	#it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  	it { is_expected.to allow_value("foo@example.com").for(:email) }
  	it { is_expected.to_not allow_value("bar@example..com").for(:email) }
  	it { is_expected.to_not allow_value("foobar@example").for(:email) } 
  end

  describe "validate password" do
  	it { should validate_presence_of(:password) }
  	it { should validate_length_of(:password).is_at_least(6) }
  end


end
