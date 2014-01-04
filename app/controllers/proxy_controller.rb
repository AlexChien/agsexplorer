class ProxyController < ApplicationController
  # params[:market]
  # params[:pair]
  def ticker
    market  = params[:market] || 'bter'
    pair    = params[:pair] || 'pts_btc'

    api_url = "https://bter.com/api/1/ticker/#{pair}"

    begin
      resp = RestClient.get api_url, :timeout => 2
    rescue
      resp = nil
    end

    respond_to do |format|
      format.json { render_json resp }
      format.js   { render_json resp }
    end
  end

  def render_json(json)
    callback = params[:callback]
    response = begin
      if callback
        "#{callback}(#{json});"
      else
        json
      end
    end
    render({:content_type => :js, :text => response})
  end

end
