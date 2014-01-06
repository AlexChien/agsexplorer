class BalancesController < ApplicationController
  def show
    @donations = Donation.get_donations_by_address(params[:address]) unless params[:address].blank?
    @network = @donations.first.try(:network) || :btc

    unless @donations.blank?
      @total_donated = @donations.map(&:amount).sum

      @today_total_donated = Donation.where(network: @network).by_date.first.try(:total)

      today = Time.zone.now.to_date.beginning_of_day

      @total_ags_confirmed = @donations.select{ |d| d.time < today }.map(&:ags_amount).sum
      @total_ags_pending = @donations.select{ |d| d.time >= today }.map(&:amount).sum.to_f / @today_total_donated * Ags.daily_issue(@network.to_sym)
    end
  end
end
