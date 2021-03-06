class HomeController < ApplicationController
  def index
    # ags
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

    # music
    @music_daily_data = MusicDonation.daily
    @music_today = MusicDonation.by_date
    @music_data = {
      today_btc_donations: MusicDonation.btc.today_donations,
      today_btc_donated:   MusicDonation.today_donated(:btc),
      btc_current_price:   MusicDonation.current_price(:btc),
    }

    @music_summary = {}
    MusicDonation.summary.all.each do |summary|
      @music_summary[summary.network.to_sym] = {total: summary.total, count: summary.count}
    end if music_donation_finished?

    # play
    @play_daily_data = PlayDonation.daily
    @play_today = PlayDonation.by_date
    @play_data = {
      today_btc_donations: PlayDonation.btc.today_donations,
      today_btc_donated:   PlayDonation.today_donated(:btc),
      btc_current_price:   PlayDonation.current_price(:btc) * PlayCrowdfund::COIN,
      total_donated:       PlayDonation.total_donated(:btc)
    }

    @play_summary = {}
    PlayDonation.summary.all.each do |summary|
      @play_summary[summary.network.to_sym] = {total: summary.total, count: summary.count}
    end if play_crowdfund_finished?

    render :index_after_donation_finished and return if donation_finished?
  end

  def by_date
    @date = begin
      @by_date = true
      Date.parse(params[:date])
    rescue
      Time.zone.now.to_date
    end

    @project = params[:project]

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

    @summary = {}
    Donation.summary.all.each do |summary|
      @summary[summary.network.to_sym] = {total: summary.total, count: summary.count}
    end if donation_finished?

    @music_daily_data = MusicDonation.daily
    @music_today = MusicDonation.by_date(@date.beginning_of_day)
    @music_data = {
      today_btc_donations: MusicDonation.btc.today_donations(@date),
      today_btc_donated:   MusicDonation.today_donated(:btc, @date),
      btc_current_price:   MusicDonation.current_price(:btc, @date),
      current_btc_donated: MusicDonation.today_donated(:btc),
    }

    @music_summary = {}
    MusicDonation.summary.all.each do |summary|
      @music_summary[summary.network.to_sym] = {total: summary.total, count: summary.count}
    end if music_donation_finished?

    # play
    @play_daily_data = PlayDonation.daily
    @play_today = PlayDonation.by_date(@date.beginning_of_day)
    @play_data = {
      today_btc_donations: PlayDonation.btc.today_donations(@date),
      today_btc_donated:   PlayDonation.today_donated(:btc, @date),
      btc_current_price:   PlayDonation.current_price(:btc, @date) * PlayCrowdfund::COIN,
      total_donated:       PlayDonation.total_donated(:btc)
    }

    @play_summary = {}
    PlayDonation.summary.all.each do |summary|
      @play_summary[summary.network.to_sym] = {total: summary.total, count: summary.count}
    end if play_crowdfund_finished?

    render :index_after_donation_finished
  end

  def ags101
  end

  def daily_series(networks = nil, start_date = nil, end_date = nil)
    if params[:networks].present?
      networks = params[:networks]
    end

    if networks == 'music'
      end_date = (MusicPresale::END_DATE).to_date.to_s if end_date.nil?
      @daily_data = MusicDaily.series(networks, start_date, end_date)
    elsif networks == 'play'
      end_date = (PlayCrowdfund::END_DATE).to_date.to_s if end_date.nil?
      @daily_data = PlayDaily.series(networks, start_date, end_date)
    else
      end_date = (Ags::END_DATE).to_date.to_s if end_date.nil?
      @daily_data = Daily.series(networks, start_date, end_date)
    end

    respond_to do |format|
      format.html
      format.json { render json: @daily_data.as_json, :callback => params[:callback] }
      format.xml { render xml: @daily_data.to_xml(only: [:date, :amount]) }
    end
  end

  def total
    dac     = (params[:dac] || 'play').downcase
    @network = (params[:network] || 'btc').downcase

    @total = case dac
    when 'music'
      @network = 'btc'
      MusicDonation.btc.sum(:amount)
    when 'play'
      @network = 'btc'
      PlayDonation.btc.sum(:amount)
    when 'ags'
      Donation.send(:network).sum(:amount)
    end

    @data = {
      dac: dac, network: @network, total: @total
    }

    respond_to do |format|
      format.html
      format.json { render json: @data.as_json, :callback => params[:callback] }
      format.xml { render xml: @data.to_xml }
    end
  end

  def ticker(campaign = nil, network = nil)
    campaign ||= params[:campaign].try(:downcase) || 'music'
    network ||= campaign == 'music' ? 'btc' : (params[:network] || 'btc')

    if campaign == 'music'
      @daily_data = MusicDonation.ticker(network)
    elsif campaign == 'ags'
      @daily_data = Donation.ticker(network)
    else
      render :text => "" and return
    end

    respond_to do |format|
      format.html
      format.json { render json: @daily_data.as_json }
      format.xml { render xml: @daily_data.to_xml(only: [:date, :amount]) }
    end
  end
end
