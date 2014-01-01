class BlocksController < ApplicationController
  before_filter :get_store, :only => [:show_by_hash, :show_by_height]
  def show_by_hash
    render :text => "no currency assigned" unless @network

    @block = @store.get_block(params[:hash])

    render :show
  end

  def show_by_height
    render :text => "no currency assigned" unless @network

    @block = @store.get_block_by_depth(params[:height].to_i)

    render :show
  end

  def is_depth?(str)
    str =~ /\d+/ && str.to_i.to_s.length == str.to_s.length
  end

  def is_hash?(str)
    str =~ /\d+/ && str.to_i.to_s.length != str.to_s.length
  end

end