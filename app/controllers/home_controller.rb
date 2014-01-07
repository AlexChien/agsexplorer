class HomeController < ApplicationController
  def index
    @daily_data = Donation.daily
    @today = Donation.by_date

    @today_btc_nonations = Donation.btc.today_donations
    @today_pts_nonations = Donation.pts.today_donations

    # @today_btc_donated  = Donation.today_donated(:btc)
    # @today_pts_donated  = Donation.today_donated(:pts)
  end
end
