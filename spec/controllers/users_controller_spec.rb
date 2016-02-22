require 'rails_helper'

RSpec.describe UsersController, type: :controller do

	context "GET new" do
		it "returns http success" do
			get :new
			expect(response).to have_http_status(:success)
		end
	end

	context "GET show" do
		it "returns http forbidden" do
			params = { id: 1 }
			get :show , params
			expect(response).to have_http_status(:forbidden)
		end
	end

end
