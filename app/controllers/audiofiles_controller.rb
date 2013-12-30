class AudiofilesController < ApplicationController
	before_action :authenticate_user!
	respond_to :html,  :json

	def index
		@audiofile=Audiofile.new
		@au = current_user.audiofiles if current_user.present?
	end

	def create
		@audiofile = Audiofile.create(safe_params)
		SisWorker.perform_async(@audiofile.old_path, @audiofile.new_path)
		respond_with(@audiofile, :location => root_url)
	end

	def destroy
		@audiofile = Audiofile.find(params[:id])
	    @audiofile.destroy

	    respond_with(@audiofile, :location => root_url)
	end

	def download
		@audiofile = Audiofile.find(params[:id])
		if File.exist?(@audiofile.new_path)
			send_file @audiofile.url, :disposition => 'attachment'
		else
			flash[:error] = "File incompatible with this service. Please, delete it." 
			redirect_to audiofiles_path
		end
	end

	private

    def safe_params
    	params.require(:audiofile).permit(:owner, :description, :audio )
    end

end
