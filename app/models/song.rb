class Song < ActiveRecord::Base

  #########################
  # Attributes & Constants
  #########################
  FILE_NAME_HASH_SECRET = "CROUOPQNDKUCBVYTQYQLUSKCOMJAQFEWXMEX"
  attr_accessible :show_id, :title, :position, :song_file, :song_collection_ids

  ########################
  # Associations & Scopes
  ########################
  has_many :song_collections_songs, :dependent => :destroy
  has_many :song_collections, :through => :song_collections_songs
  has_many :section_markers
  belongs_to :show
 
  default_scope order :position
  has_attached_file :song_file,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET

  ##############
  # Validations
  ##############
  validates_attachment :song_file, :presence => true,
    :content_type => {:content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3']}
  validates_presence_of :show, :title, :position
  validates_uniqueness_of :position, :scope => :show_id
  validate :require_at_least_one_song_collection

  ############
  # Callbacks
  ############
  before_validation :populate_song_collection, :populate_position
  after_save :set_duration

  protected

  def set_duration
    unless self.duration # this won't record the correct duration if we're uploading a new file
      Mp3Info.open song_file.path do |mp3|
        self.duration = (mp3.length * 1000).round
        save
      end
    end
  end

  def populate_song_collection
    if self.song_collections.empty?
      sc = SongCollection.where 'lower(title) = ?', self.title.downcase
      self.song_collections << sc if sc
    end
  end

  def populate_position
    # If we don't have a position and there is at least 1 previous song in the show
    if !self.position && !(last_song = Song.where(:show_id => show.id).last).nil?
      self.position = last_song.position + 1
    elsif !self.position
      self.position = 1
    end
  end

  def require_at_least_one_song_collection
    errors.add(:song_collections, "Please add at least one song collection") if song_collections.empty?
  end
end
