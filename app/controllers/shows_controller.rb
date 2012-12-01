class ShowsController < ApplicationController
  
  include DownloadableTracks
  
  def index
    if params[:year]
      get_shows_by_year
      render "shows_by_year"
    else
      redirect_to root_path
    end
  end

  def show
    @show = Show.find params[:id]
  end

  def new
    @show = Show.new
  end

  def create
    @show = Show.create(params[:show])
    if @show
      redirect_to shows_path
    end
  end

  def destroy
    show = Show.find params[:id]
    if show.destroy
      redirect_to shows_path
    end
  end
  
  # Provide the tracks as a downloadable ZIP
  def download
    tracks = []
    show = Show.where("show_date = ?", params[:id]).first
    if show
      download_tracks(show.tracks.order(:position).all)
    end
  end

  private

  def get_shows_by_year
    @year = params[:year]
    @shows = Show.for_year @year
  end
end