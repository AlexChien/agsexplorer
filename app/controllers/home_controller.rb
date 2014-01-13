class HomeController < ApplicationController
  def index
    @daily_data = Donation.daily
    @today = Donation.by_date

    @data = {
      today_btc_donations: Donation.btc.today_donations,
      today_pts_donations: Donation.pts.today_donations,
      today_btc_donated:   Donation.today_donated(:btc),
      today_pts_donated:   Donation.today_donated(:pts),
      btc_current_price:   Donation.current_price(:btc),
      pts_current_price:   Donation.current_price(:pts)
    }
  end
end
