require 'spec_helper'

describe AudiofilesController do
	 render_views
	let(:user) { create(:user) }

    describe "Audiofiles" do
      it "need log in first" do
        get :index
        response.should redirect_to '/users/sign_in'
      end

		it "should view form for upload if signed in" do
		  sign_in(user)
		  get :index
		  expect(response.body).to match /Add audiofile/m
		end
	  
	  it "should view user's files if signed in" do
	    sign_in(user)
	  	audiofile = create(:audiofile_mp3)
	    get :index
	    response.should be_success
	    expect(response.body).to match /new file/m
	  end

	  it "redirects to file list after upload" do
	    sign_in(user)
	  	audio = Rack::Test::UploadedFile.new(Rails.root + 'public/mp3.mp3', 'audio/mp3')
	  	audiofile = Audiofile.new
	    post :create, :audiofile => {:owner => "1", :description => "new file", :audio => audio }
	    response.should redirect_to(root_url)
	  end

	it "destroys the requested file" do
       sign_in(user)
	  	audiofile = create(:audiofile_mp3)
        expect {
          delete :destroy, {:id => audiofile.to_param}
        }.to change(user.audiofiles, :count).by(-1)
     end

	  it "redirects to file list after destroy" do
	    sign_in(user)
	  	audiofile = create(:audiofile_mp3)
	    delete :destroy, {:id => 1}
	    response.should redirect_to(root_url)
	  end

	  it "should not download if not logged" do
	    audiofile = create(:audiofile_mp3)
	    get :download, {:id => "1"}
	    response.should redirect_to '/users/sign_in'
	  end


	end
end