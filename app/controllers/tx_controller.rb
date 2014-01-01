class TxController < ApplicationController
  before_filter :get_store, :only => [:show_by_hash, :show_by_id]

  def show_by_hash
    @tx = @store.get_tx(params[:hash])
    @block = @tx.get_block
    render :show
  end

  def show_by_id
    @tx = @store.get_tx_by_id(params[:tx_id])
    @block = @tx.get_block
    render :show
  end
end
