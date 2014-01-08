class ProxyController < ApplicationController
  # params[:market]
  # params[:pair]
  def ticker
    market  = params[:market] || 'bter'
    pair    = params[:pair] || 'pts_btc'

    t = Ticker.where(market: market, pair: pair).order("created_at desc").first
    json = "{\"last\": \"#{t.last.to_f}\", \"timestamp\": \"#{t.created_at.to_s(:db)}\"}" unless t.nil?

    respond_to do |format|
      format.json { render json: json }
      format.js   { render json: json, callback: params[:callback] }
    end
  end
end
