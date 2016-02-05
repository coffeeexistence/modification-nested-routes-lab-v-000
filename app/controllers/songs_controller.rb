class SongsController < ApplicationController
  def index
    if params[:artist_id]
      @artist = Artist.find_by(id: params[:artist_id])
      if @artist.nil?
        redirect_to artists_path, alert: "Artist not found"
      else
        @songs = @artist.songs
      end
    else
      @songs = Song.all
    end
  end

  def show
    if params[:artist_id]
      @artist = Artist.find_by(id: params[:artist_id])
      @song = @artist.songs.find_by(id: params[:id])
      if @song.nil?
        redirect_to artist_songs_path(@artist), alert: "Song not found"
      end
    else
      @song = Song.find(params[:id])
    end
  end

  def new
    if params[:artist_id]  
      valid_artist? ? (@song = Song.new(artist_id: params[:artist_id])) : (redirect_to artists_path)
    else
      (@song = Song.new)
    end
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      redirect_to @song
    else
      render :new
    end
  end

  def edit
    if params[:artist_id]
      if valid_for_editing?
        (@song = Song.find(params[:id]))
      else
        if !valid_artist? 
          redirect_to artists_path
        elsif !valid_song?
          redirect_to artist_songs_path 
        elsif !same_artist_as_nested_artist?
          redirect_to artists_path
        else
          redirect_to artists_path
        end
      end

    else
      @song = Song.find(params[:id])
    end

  end

  def update
    @song = Song.find(params[:id])

    @song.update(song_params)

    if @song.save
      redirect_to @song
    else
      render :edit
    end
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    flash[:notice] = "Song deleted."
    redirect_to songs_path
  end

  private

  def song_params
    params.require(:song).permit(:title, :artist_name, :artist_id)
  end

  def valid_for_editing?
    if !valid_song?
      flash[:notice] = "Invalid Song."
      false
    elsif !valid_artist?  
      flash[:notice] = "Invalid Artist."
      false
    elsif !same_artist_as_nested_artist?
      flash[:notice] = "Artist URL doesn't match Song's Artist."
      false
    end
  end

  def valid_artist?
    Artist.exists?(params[:artist_id])
  end

  def my_artist
    Artist.find(params[:artist_id])
  end

  def valid_song?
    Song.exists?(params[:id])
  end

  def same_artist_as_nested_artist?
    Artist.find(params[:artist_id])==Song.find(params[:id]).artist
  end

end

