module ApplicationHelper
  #DRY flash messages
  # supported types by bootstrap
  #   error
  #   success
  #   info
  def flash_message
    messages = ""
    [:notice, :info, :alert, :warning, :error].each do|type|
      if flash[type]
        messages = "<div class='alert alert-#{type}'><a class='close' data-dismiss='alert'>&times;</a>#{flash[type]}</div>"
      end
    end
    messages
  end

  def html_title(*args)
    if args.empty?
      title = mobile_device? ? [] : [APP_CONFIG[:site_title]]
      title << @html_title if @html_title
      title.compact.join(' - ')
    else
      @html_title ||= []
      @html_title << args
    end
  end

  def html_keyword(*args)
    if args.empty?
      keyword = [APP_CONFIG[:site_keyword]]
      keyword << @html_keyword if @html_keyword
      keyword.compact.join(' - ')
    else
      @html_keyword ||= []
      @html_keyword << args
    end
  end

  def html_description(*args)
    if args.empty?
      description = [APP_CONFIG[:site_description]]
      description << @html_description if @html_description
      description.compact.join(' - ')
    else
      @html_description ||= []
      @html_description << args
    end
  end

  def page_name
    "#{params[:controller].parameterize}_#{params[:action].parameterize}"
  end

  def page_id(path = request.path)
    if path == '/'
      path = '/home/index'
    end
    path.gsub(/^\//,'').gsub("/",'_')
  end

  def display_time(timestamp)
    Time.at(timestamp).utc.to_s(:db)
  end

  def display_currency(satoshi, currency = "bitcoin")
    symbol = network_short_name(currency)
    satoshi == 0 ? "0 #{symbol}" : "#{satoshi / Bitcoin::COIN.to_f} #{symbol}"
  end

  def network_short_name(network = "bitcoin")
    case network.to_sym
    when :btc, :bitcoin
      "BTC"
    when :pts, :protoshare
      "PTS"
    end
  end

  def is_btc?(network)
    network_short_name(network) == "BTC"
  end

  def is_pts?(network)
    network_short_name(network) == "PTS"
  end
end
