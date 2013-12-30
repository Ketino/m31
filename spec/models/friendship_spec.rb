require 'spec_helper'

describe Friendship do
	it "friendship have user and friend" do
		user = create(:user)
		user2 = create(:user)
		fr = create(:friendship)
		expect(fr.user).to be_a(User)
		expect(fr.friend).to be_a(User)
	end

	it "friendship without user_id and friend_id failed" do
		@fr =Friendship.new() 
		@fr.valid?
		expect(@fr.errors.messages.count).to be(2)
	end

	it "friendship with user_id and friend_id valid" do
		@fr =Friendship.new({user_id: 1, friend_id: 2}) 
		@fr.valid?
		expect(@fr.errors.messages.count).to be(0)
	end
end
