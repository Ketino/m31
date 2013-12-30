class SisWorker
	include Sidekiq::Worker
  
	def perform(old_path, new_path)
		system "ffmpeg -i '#{old_path}' -f wav - | lame - -B 64 -m m tmp.tmp  && rm '#{old_path}' && mv tmp.tmp '#{new_path}' "
	end

end