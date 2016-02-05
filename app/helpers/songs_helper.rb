module SongsHelper
	def nested?
		!!params[:artist_id]
	end
end
