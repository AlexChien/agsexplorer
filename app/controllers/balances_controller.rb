class BalancesController < ApplicationController
  def show
    @address = params[:address].try(:strip)
    @view = params[:view] || "merged"

    # try to find donating address
    if (@donation = Donation.where(address: @address).limit(1).first).nil?
      # not found, try to find it in wallet addresses
      @wallet = WalletAddress.where(address: @address).first.try(:wallet)

      # force into merged view
      @view = 'merged'
    else
      @wallet = Donation.where(address: @address).limit(1).first.try(:wallet)
    end

    unless @wallet.nil?
      # donation addresses
      @addresses = Donation.where(wallet_id: @wallet.try(:wallet_id)).pluck("distinct address")

      # related_addresses
      @related_addresses = @wallet.addresses.map(&:address)

      # decide view
      @donations = Donation.where(address: @view == 'seperate' ? @address : @addresses).order('time desc') unless @addresses.blank?

      @network = @donations.try(:first).try(:network) || :btc
      @avg_donation_amount = Donation.avg_donation(@network.to_sym)

      unless @donations.blank?
        @total_donated = @donations.map(&:amount).sum

        @today_total_donated = Donation.where(network: @network).by_date.first.try(:total) || 0

        today = Time.zone.now.to_date.beginning_of_day

        @total_ags_confirmed = @donations.select{ |d| d.time < today }.map(&:ags_amount).sum
        @total_ags_pending = @donations.select{ |d| d.time >= today }.map(&:amount).sum.to_f / @today_total_donated * Ags.daily_issue(@network.to_sym)
      end
    else
      # non-ags address
      @related_addresses = [@address]
      @addresses = []
      @total_donated = @total_ags_pending = @total_ags_confirmed = 0
      @network = @address =~ /^P/ ? :pts : :btc
    end

  end

  def masterbook
    @network = params[:network] || 'btc'
    @donations = Donation.where(network: @network).where("time < ?", Time.now.utc.to_date).order("address asc")

    if params[:date]
      date = Date.parse(params[:date])
      @donations = @donations.where('time < ?', date.tomorrow)
    end

    if params[:address]
      @donations = @donations.where(address: params[:address])
    end

    @donations = @donations.group("address").select("address, sum(ags_amount) as ags_amount")

    if params[:per_page] != "-1"
      @donations = @donations.paginate(:per_page => per_page, :page => params[:page])
    end

    respond_to do |format|
      format.html
      format.json { render json: @donations.as_json(only: [:address, :ags_amount]) }
      format.xml { render xml: @donations.to_xml(only: [:address, :ags_amount]) }
    end
  end
end
