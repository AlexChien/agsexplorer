class HomeController < ApplicationController
  def index
    @date = Time.zone.now.to_date
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

    @summary = {}
    Donation.summary.all.each do |summary|
      @summary[summary.network.to_sym] = {total: summary.total, count: summary.count}
    end if donation_finished?

    render :index_after_donation_finished and return if donation_finished?
  end

  def by_date
    @date = begin
      Date.parse(params[:date])
    rescue
      Time.zone.now.to_date
    end

    redirect_to root_path and return if @date == Time.zone.now.to_date

    @daily_data = Donation.daily
    @today = Donation.by_date(@date.beginning_of_day)

    @data = {
      today_btc_donations: Donation.btc.today_donations(@date),
      today_pts_donations: Donation.pts.today_donations(@date),
      today_btc_donated:   Donation.today_donated(:btc, @date),
      today_pts_donated:   Donation.today_donated(:pts, @date),
      btc_current_price:   Donation.current_price(:btc, @date),
      pts_current_price:   Donation.current_price(:pts, @date),
      current_btc_donated: Donation.today_donated(:btc),
      current_pts_donated: Donation.today_donated(:btc)
    }

    render :index
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
