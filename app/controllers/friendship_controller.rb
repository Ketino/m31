class FriendshipController < ApplicationController
	before_action :authenticate_user!
	def index
		@friends = current_user.friends
	end
	
	def show
		@friend = User.find(params[:id])
		if @friend.friends.include?(current_user)
			@au = @friend.audiofiles
		else
			@au=[]
		end
		@friendship = current_user.friendships.where(:friend_id => params[:id])
		unless @friendship.blank?
			@lastvisited = @friendship.first.updated_at
			@au_new = @friend.audiofiles.where("updated_at > ?",@lastvisited)
			@friendship.first.touch
		else
			@au_new = []
		end
	end

	def search
		@newfriends =  User.all.search(safe_params)
	end

	def update
	  if exist?
	  	flash[:error] = "Unable to add twice."
	  else
		  @friendship = current_user.friendships.build(:friend_id => params[:id])
		  if @friendship.save
		    flash[:notice] = "Added friend."
		  else
		    flash[:error] = "Unable to add friend."
		  end
	  end
	  redirect_to friendship_index_path
	end

	def destroy
	  @friendship = current_user.friendships.where("friend_id = ?", params[:id]).first
	  @friendship.destroy if @friendship
	  flash[:notice] = "Removed friendship."
  	  redirect_to friendship_index_path
	end
	
	private

	def exist?
		return true if current_user.id.to_s == params[:id] 
		current_user.friendships.exists?(:friend_id => params[:id])
	end

	def safe_params
    	params.permit(:email, :username )
    end
end
