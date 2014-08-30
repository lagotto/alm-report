module ApplicationHelper

  def switch(template)
    case APP_CONFIG['mode']
    when 'plos'
      render "home/plos/#{template}"
    when 'default'
      render "home/default/#{template}"
    end
  end

  def method_missing(template)
    if %i[logo footer_logo font side_heading links_holder stylesheet].include?(template)
      switch(template)
    else
      super
    end
  end
end
