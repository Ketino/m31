# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :audiofile_mp3, :class => 'Audiofile' do
    description "new file"
    owner "1"
    audio   Rack::Test::UploadedFile.new(Rails.root + 'public/mp3.mp3', 'audio/mp3')
  end
end
