class HomeController < ApplicationController
  def index
    @daily_data = Donation.daily
    @today = Donation.by_date

    @today_btc_nonations = Donation.btc.today_donations
    @today_pts_nonations = Donation.pts.today_donations
  end
end
