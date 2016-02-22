require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do

	context "GET home" do 
		it "returns http success" do
			get :home
			expect(response).to have_http_status(:success)
			expect(response).to render_template(:home)
		end
	end

	context "GET help" do
		it "returns http success" do
			get :help
			expect(response).to have_http_status(:success)
			expect(response).to render_template(:help)
		end
	end

	context "GET about" do
		it "returns http success" do
			get :about
			expect(response).to have_http_status(:success)
			expect(response).to render_template(:about)
		end
	end

	context "GET contact" do
		it "returns http success" do
			get :contact
			expect(response).to have_http_status(:success)
			expect(response).to render_template(:contact)
		end
	end




end
