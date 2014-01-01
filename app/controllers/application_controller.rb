class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |e|
    unless Rails.env.production?
      Rails.logger.debug "Access denied on #{e.action} #{e.subject.inspect}"
    end
    render_403
  end

  # parse work from request param
  def get_network(str = nil)
    return false if str.nil?

    case str.downcase
    when "btc","bitcoin"
      @network = :bitcoin
    when "pts","protoshare"
      @network = :protoshare
    else
      false
    end
  end

  def get_store
    if @network = get_network(params[:network])
      backend, config = APP_CONFIG[@network]["storage"].split("::")
      @store = Bitcoin::Storage.send(backend, { db: config, cache_head: true })
    else
      return false
    end
  end

  def render_403(options={})
    options.merge(:layout => !request.xhr?)
    respond_to do |format|
      format.html { render :template => "common/403", :layout => options[:layout], :status => 403 }
      format.xml { render :xml => {:error_code => 403, :message => "403 Forbidden"}, :root => "data", :status => :forbidden }
      format.rss { render :xml => {:error_code => 403, :message => "403 Forbidden"}, :root => "data", :status => :forbidden }
      format.json { render :json => {:error_code => 403, :message => "403 Forbidden"}, :status => :forbidden }
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :template => "common/404", :layout => !request.xhr?, :status => 404 }
      format.xml { render :xml => {:error_code => 404, :message => "404 Not Found"}, :root => "data", :status => 404 }
      format.rss { render :xml => {:error_code => 404, :message => "404 Not Found"}, :root => "data", :status => 404 }
      format.json { render :json => {:error_code => 404, :message => "404 Not Found"}, :status => 404 }
    end
  end

  def render_501
    respond_to do |format|
      format.any { render :text => "501 not implemented", :status => 501 }
    end
  end

  def render_error(msg)
    flash.now[:error] = msg
    render :text => '', :layout => !request.xhr?, :status => 500
  end


  def per_page
    @per_page ||= APP_CONFIG[:per_page]
  end


  # production use nginx to send files
  def x_sendfile(path,file_name)
    if Rails.env == 'production'
      send_file path
    else
      send_data File.read(path),:filename=>file_name
    end
  end

  def mobile_device?
    false
  end
  helper_method :mobile_device?
end
