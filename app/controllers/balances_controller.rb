class BalancesController < ApplicationController
  def show
    @donations = Donation.get_donations_by_address(params[:address]) unless params[:address].blank?
    @network = @donations.first.network

    unless @donations.empty?
      @total_donated = @donations.map(&:amount).sum

      today = Date.today.to_time(:utc)

      @total_ags_confirmed = @donations.select{ |d| d.time < today }.map(&:ags_amount).sum
      @total_ags_pending = @donations.select{ |d| d.time >= today }.map(&:ags_amount).sum
    end
  end
end
