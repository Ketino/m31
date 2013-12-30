class CreateAudiofiles < ActiveRecord::Migration
  def change
    create_table :audiofiles do |t|
      t.string 		:description
      t.integer 	:owner
    	t.string  	:audio_file_name
    	t.string  	:audio_content_type
    	t.integer 	:audio_file_size
    	t.datetime	:audio_updated_at

      t.timestamps
    end
  end
end
