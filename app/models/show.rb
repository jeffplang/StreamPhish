class Show < ActiveRecord::Base
  attr_accessible :show_date, :location

  has_many :songs
  scope :for_year, lambda { |year|
    if year == '83-87'
      where 'show_date between ? and ?', Date.new(1983).beginning_of_year, Date.new(1987).end_of_year
    else
      date = Date.new(year.to_i)
      where 'show_date between ? and ?', date.beginning_of_year, date.end_of_year
    end
  }

  validates_presence_of :show_date, :location

  extend FriendlyId
  friendly_id :show_date

  def to_s
    "#{show_date.strftime('%m-%d-%Y')} - #{location}"
  end
  alias_method :title, :to_s # for rails admin
end
