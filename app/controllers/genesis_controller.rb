class GenesisController < ApplicationController
  # address could be _ seperated multiple address
  # /genesis/bts/a_b.json will return address [a,b] genesis info
  def balance
    dac = params[:dac].try(:upcase)
    address = params[:address]

    if address.present? && (addrs = address.split('_')).size > 0
      address = addrs
    end

    # if music, we calculate ongoing donation
    if dac == 'MUSIC' && !music_donation_finished?

      today = Time.zone.now.to_date.beginning_of_day
      md_confirmed   = MusicDonation.where(address: address).
                       where('time < ?', today).group(:address).sum(:ags_amount)
      md_unconfirmed = MusicDonation.where(address: address).
                       where('time >= ?', today).group(:address).sum(:amount)
      md_today_total = MusicDonation.where('time >= ?', today).sum(:amount)

      if md_confirmed.size > 0
        @result = []
        md_confirmed.each do |e|
          @result.push({ dac: "MUSIC", address: e.first, amount: e.last, unconfirmed: md_unconfirmed[e.first].to_f / md_today_total * MusicPresale::ISSURANCE[:btc] })
        end

      else
        @result = { dac: dac, address: address, amount: 0 }
      end

    else

      # look up through dac genesis block data
      @balance = DacGenesis.where(dac:dac, address:address).group(:dac, :address).sum(:amount)

      # if not found, return 0 amount
      if @balance.nil?
        @result = { dac: dac, address: address, amount: 0 }
      else
        @result = []
        @balance.each do |k,v|
          @result.push({ dac: k[0], address: k[1], amount: v })
        end
      end

    end

    respond_to do |format|
      format.json { render json: @result.as_json }
      format.xml { render xml: @result.to_xml }
    end

  end
end
