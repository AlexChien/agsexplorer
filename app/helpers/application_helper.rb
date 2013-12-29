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
end
