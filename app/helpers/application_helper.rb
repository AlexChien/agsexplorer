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

  # amount in satoshi unit
  def display_currency(amount, currency = "bitcoin", pretty = false)
    symbol = network_short_name(currency)
    if pretty
      small(amount / Bitcoin::COIN.to_f, symbol)
    else
      amount == 0 ? "0 #{symbol}" : "#{amount / Bitcoin::COIN.to_f} #{symbol}"
    end
  end

  # display_currency with pretty
  def dcp(amount, currency = "bitcoin")
    display_currency(amount, currency, true).html_safe
  end

  def small(num, symbol)
    parts = num.to_s.split('.')
    if parts.size == 2
      "#{number_with_delimiter(parts.first.to_i)}<small class='num'>.#{parts.last.first(8)} #{symbol}</small>"
    else
      "#{number_with_delimiter(parts.first.to_i)}<small class='num'>.0 #{symbol}</small>"
    end
  end

  def network_short_name(network = "bitcoin")
    case network.to_sym
    when :btc, :bitcoin
      "BTC"
    when :pts, :protoshare
      "PTS"
    when :ags, :angelshare
      "AGS"
    end
  end

  def is_btc?(network)
    network_short_name(network) == "BTC"
  end

  def is_pts?(network)
    network_short_name(network) == "PTS"
  end
end
