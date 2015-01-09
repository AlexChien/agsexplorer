class GenesisController < ApplicationController
  # address could be _ seperated multiple address
  # /genesis/bts/a_b.json will return address [a,b] genesis info
  def balance
    dac = params[:dac].try(:upcase)
    address = params[:address]

    if address.present? && (addrs = address.split('_')).size > 0
      address = addrs
    end

    render :text => "address is missing" and return if address.blank?

    # if music, we calculate ongoing donation
    if dac == 'MUSIC' #&& !music_donation_finished?

      today = Time.zone.now.to_date.beginning_of_day
      md_confirmed   = MusicDonation.where(address: address).
                       where('time < ?', today).group(:address).sum(:ags_amount)
      md_unconfirmed = MusicDonation.where(address: address).
                       where('time >= ?', today).group(:address).sum(:amount)
      md_today_total = MusicDonation.where('time >= ?', today).sum(:amount)

      @result = []
      address.each do |addr|
        @result.push ({
          dac: "MUSIC", address: addr,
          amount: md_confirmed[addr] || 0,
          unconfirmed: md_today_total == 0 ? 0 : md_unconfirmed[addr].to_f / md_today_total * MusicPresale::ISSURANCE[:btc]
        })
      end

    # if play, we calculate ongoing donation
    elsif dac == 'PLAY'
      today = Time.zone.now.to_date.beginning_of_day
      md_confirmed   = PlayDonation.where(address: address).
                       where('time < ?', today.tomorrow).group(:address).sum(:ags_amount)
      # md_unconfirmed = MusicDonation.where(address: address).
      #                  where('time >= ?', today).group(:address).sum(:amount)
      md_today_total = PlayDonation.where('time >= ?', today).sum(:amount)

      @result = []
      address.each do |addr|
        @result.push ({
          dac: "PLAY", address: addr,
          amount: md_confirmed[addr] || 0,
          unconfirmed: 0
        })
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
