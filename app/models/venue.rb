class Venue < ActiveRecord::Base
  attr_accessible :name, :past_names, :city, :state, :country
  
  has_many :shows

end