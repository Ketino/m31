class Audiofile < ActiveRecord::Base
	belongs_to :user, foreign_key: "owner"
	validates_presence_of :owner
	validates_presence_of :audio
	default_scope {order('created_at DESC')}

  has_attached_file :audio,
  	:url => "public/sounds/:id/:basename.mp3",
  	:path => ":rails_root/public/sounds/:id/:basename.:extension"

    def new_path
      "#{Rails.root}/#{audio.url('',false)}"
    end

    def old_path
      audio.path
    end

  	def url
  		audio.url("",false)
  	end

end
