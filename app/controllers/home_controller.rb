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

  def ags101
  end

  def daily_series(networks = nil, start_date = nil, end_date = nil)
    @daily_data = Daily.series(networks, start_date, end_date)

    respond_to do |format|
      format.html
      format.json { render json: @daily_data.as_json }
      format.xml { render xml: @daily_data.to_xml(only: [:date, :amount]) }
    end
  end
end
