class GenesisController < ApplicationController
  # address could be _ seperated multiple address
  # /genesis/bts/a_b.json will return address [a,b] genesis info
  def balance
    dac = params[:dac].try(:upcase)
    address = params[:address]

    if address.present? && (addrs = address.split('_')).size > 0
      address = addrs
    end

    @balance = DacGenesis.where(dac:dac, address:address)
    # if not found, return 0 amount
    if @balance.nil?
      @balance = {dac:dac, address:address, amount:0}
    end

    respond_to do |format|
      format.json { render json: @balance.as_json(only: [:dac, :address, :amount]) }
      format.xml { render xml: @balance.to_xml(only: [:dac, :address, :amount]) }
    end

  end
end
