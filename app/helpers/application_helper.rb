module ApplicationHelper

  def switch(template)
    controller.prepend_view_path(["app/views/#{controller.controller_name}/",
      "app/views/application/"])
    case APP_CONFIG['mode']
    when 'plos'
      render "plos/#{template}"
    when 'default'
      render "default/#{template}"
    end
  end

  def method_missing(template)
    templates = %i(
      logo
      footer_logo
      font
      side_heading
      links_holder
      stylesheet
      articles_list
      footer
    )
    if templates.include?(template)
      switch(template)
    else
      super
    end
  end
end
