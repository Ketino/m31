require 'spec_helper'

describe Audiofile do
	before(:each) do
  	end

	it "audiofile have owner" do
		user = create(:user)
		@audio = create(:audiofile_mp3)
		expect(@audio.user).to be_a(User)
	end

	it "audiofile have attached file with url" do
		@audio = create(:audiofile_mp3)
		expect(@audio.audio.url("",false)).to eq("public/sounds/1/mp3.mp3")
	end

	it "audiofile must have  old_path, new_path and url" do
		@audio = create(:audiofile_mp3)
		@test_path = "#{Rails.root}/public/sounds/1/mp3.mp3"
		expect(@audio.new_path).to eq(@test_path)
		expect(@audio.old_path).to eq(@test_path)
		expect(@audio.url     ).to eq("public/sounds/1/mp3.mp3")
	end

	it "audiofile without owner and audio failed" do
		@audio =Audiofile.new() 
		@audio.valid?
		expect(@audio.errors.messages.count).to be(2)
	end

	it "audiofile with owner and audio valid" do
		@uploaded = Rack::Test::UploadedFile.new(Rails.root + 'public/mp3.mp3', 'audio/mp3')
		@audio =Audiofile.new({owner: 1, audio: @uploaded}) 
		@audio.valid?
		expect(@audio.errors.messages.count).to be(0)
	end


end
