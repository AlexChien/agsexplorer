class HomeController < ApplicationController
  def index
    @daily_data = Donation.daily
    @today = Donation.by_date
  end
end
