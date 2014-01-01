class AddressesController < ApplicationController
  before_filter :get_store, :only => [:show]

  def show
    if Bitcoin.address_type(params[:address]) == :hash160
      @address = params[:address]
      @hash160 = Bitcoin.hash160_from_address(@address)
    else
      @hash160 = params[:address]
      @address = Bitcoin.hash160_to_address(@hash160)
    end

    render :text => "The address is invalid for #{@network.upcase} network" unless Bitcoin.valid_address?(@address)

    @txs = @store.get_txouts_for_address(@address).map{ |out|
      [out.get_tx, out.get_next_in ? out.get_next_in.get_tx : nil].compact
    }.compact.flatten
  end
end
