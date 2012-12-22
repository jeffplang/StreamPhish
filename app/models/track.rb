class Track < ActiveRecord::Base
  
  require 'taglib'

  #########################
  # Attributes & Constants
  #########################
  FILE_NAME_HASH_SECRET = "CROUOPQNDKUCBVYTQYQLUSKCOMJAQFEWXMEX"
  attr_accessible :show_id, :title, :position, :song_file, :song_ids

  has_attached_file :song_file,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET

  ########################
  # Associations & Scopes
  ########################
  has_many :songs_tracks, :dependent => :destroy
  has_many :songs, :through => :songs_tracks
  has_many :section_markers, :dependent => :destroy
  belongs_to :show
  
  default_scope order('position')
  scope :chronological, order('shows.show_date ASC').joins(:show)
  
  include PgSearch
  pg_search_scope :kinda_matching,
                  :against => :title, 
                  :using => {
                    tsearch: {
                      any_word: false,
                      normalization: 16
                    }
                  }

  ##############
  # Validations
  ##############
  validates_attachment :song_file, :presence => true,
    :content_type => {:content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3']}
  validates_presence_of :show, :title, :position
  validates_uniqueness_of :position, :scope => :show_id
  validate :require_at_least_one_song

  ############
  # Callbacks
  ############
  before_validation :populate_song, :populate_position
  after_save :set_duration
  
  # Return the full name of the set given the stored codes
  def set_name
    case set
      when "1" then "Set 1"
      when "2" then "Set 2"
      when "3" then "Set 3"
      when "4" then "Set 4"
      when "E" then "Encore"
      when "E2" then "Encore 2"
      when "E3" then "Encore 3"
      else "Unknown set"
    end
  end
  
  # Return the set abbreviation (livephish.com style)
  # Roman numerals; encores are part of last set
  def set_album_abbreviation
    # Encores
    if /^E[\d]*$/.match(set)
      romanize show.last_set
    # Numbered sets
    elsif /^\d$/.match(set)
      romanize set
    else
      ""
    end
  end
  
  # Configure default ID3 tags on the track's song_file (livephish.com style)
  # Assume track order is in context of entire show
  def save_default_id3_tags
    TagLib::MPEG::File.open(song_file.path) do |file|
      # Set basic ID3 tags
      tag = file.id3v2_tag
      # if tag
        tag.title = title
        tag.artist = "Phish"
        tag.album = show.show_date.to_s + " " + set_album_abbreviation + " " + show.location
        tag.year = show.show_date.strftime("%Y").to_i
        tag.track = position
        tag.genre = "Rock"
        # tag.comment = "Visit phishtracks.net for free Phish audio" //Doesn't seem to work
        # Add cover art
        # TODO turn this back on when we have decent site art
        # apic = TagLib::ID3v2::AttachedPictureFrame.new
        # apic.mime_type = "image/jpeg"
        # apic.description = "Cover"
        # apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
        # apic.picture = File.open(Rails.root.to_s + '/app/assets/images/cover_generic.jpg', 'rb') { |f| f.read }
        # tag.add_frame(apic)
        # Save
        file.save
      # end
    end
  end

  def file_url
    song_file.to_s
  end

  def slug
    songs.first.slug
  end

  protected
  
  def set_duration
    unless self.duration # this won't record the correct duration if we're uploading a new file
      Mp3Info.open song_file.path do |mp3|
        self.duration = (mp3.length * 1000).round
        save
      end
    end
  end

  def populate_song
    if self.songs.empty?
      sc = Song.where 'lower(title) = ?', self.title.downcase
      self.songs << sc if sc
    end
  end

  def populate_position
    # If we don't have a position and there is at least 1 previous song in the show
    if !self.position && !(last_song = Track.where(:show_id => show.id).last).nil?
      self.position = last_song.position + 1
    elsif !self.position
      self.position = 1
    end
  end

  def require_at_least_one_song
    errors.add(:songs, "Please add at least one song") if songs.empty?
  end
  
  def romanize(number)
    case number
      when "1" then "I"
      when "2" then "II"
      when "3" then "III"
      when "4" then "IV"
      else ""
    end
  end
  
end
