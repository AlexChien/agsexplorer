class GenesisController < ApplicationController
  # address could be _ seperated multiple address
  # /genesis/bts/a_b.json will return address [a,b] genesis info
  def balance
    dac = params[:dac].try(:upcase)
    address = params[:address]

    if address.present? && (addrs = address.split('_')).size > 0
      address = addrs
    end

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

    respond_to do |format|
      format.json { render json: @result.as_json(only: [:dac, :address, :amount]) }
      format.xml { render xml: @result.to_xml(only: [:dac, :address, :amount]) }
    end

  end
end
