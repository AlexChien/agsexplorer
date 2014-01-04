class Bter < ActiveRecord::Base
  attr_accessible :last, :pair

  def self.fetch_ticker(pair = 'pts_btc')
    url = "https://bter.com/api/1/ticker/#{pair}"

    puts url
  end
end
