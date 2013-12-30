class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
	has_many :audiofiles, :foreign_key => "owner"
	has_many :friendships
	has_many :friends, :through => :friendships

	scope :search_user , ->(x,y) { where('username = ? OR email LIKE ?', "%#{x}%", "%#{y}%") }
	
	def self.search(params)
    	search_user(params[:username],params[:email])
	end


end
