require 'spec_helper'

describe FriendshipController do
	render_views
	let(:user) { create(:user) }


	describe "friendship not logged" do

		it "if not loggeg - no friends" do
			get :index
			response.should redirect_to '/users/sign_in'
		end
	end
	describe "friendship  logged" do
		before(:each) do
    		sign_in(user)
  		end

		it "if logged view friends list" do
			get :index
			expect(response.body).to match /Your friends/m
		end

		it "if has friend view friends email " do
			user2 = create(:user, :id => 2)
			fr = create(:friendship)
			get :index
			expect(response.body).to match /@example.com/m
		end

		it "seach friend AJAX" do
			xhr :get, :search, {email: "u"}
			expect(response.body).to match /#{user.email}/m
		end

		it "seach friend AJAX - exist" do
			xhr :get, :search, {email: "u"}
			expect(response.body).to match /#{user.email}/m
		end

		it "seach friend AJAX - not exist" do
			xhr :get, :search, {email: "xyz"}
			expect(response.body).to match /Not found/m
		end

		it "add friend - redirect" do
			get :update, {:id => '1'}
			response.should redirect_to('/friendship')
		end

		it "add friend - friedship with themself incorrect" do
			get :update, {:id => '1'}
			get :index
			expect(response.body).to match /twice/m
		end

		it "add friend seccess" do
			user2 = create(:user, :id => 2)
			get :update, {:id => '2'}
			get :index
			expect(response.body).to match /#{user2.email}/m
		end

		it "add friend twice" do
			user2 = create(:user, :id => 2)
			fr = create(:friendship)
			get :update, {:id => '2'}
			get :index
			expect(response.body).to match /twice/m
		end

		it "destroy" do
			fr = create(:friendship)
			get :destroy, {:id => '2'}
			get :index
			expect(response.body).to match /No friends yet/m
		end

	end
end
