module ApplicationHelper
  def superhumanize(thing)
    thing.to_s.gsub("-", "_").humanize
  end

  def switch(template)
    controller.prepend_view_path(["app/views/#{controller.controller_name}/",
      "app/views/application/"])
    case ENV["MODE"]
    when 'plos'
      render "plos/#{template}"
    when 'default'
      render "default/#{template}"
    end
  end

  def login_link
    case ENV['OMNIAUTH']
    when "cas" then link_to "Sign in with PLOS ID", user_omniauth_authorize_path(:cas), id: "sign_in"
    when "github" then link_to "Sign in with Github", user_omniauth_authorize_path(:github), id: "sign_in"
    when "orcid" then link_to "Sign in with ORCID", user_omniauth_authorize_path(:orcid), id: "sign_in"
    else
      form_tag "/users/auth/persona/callback", id: "persona_form" do
        hidden_field_tag('assertion') +
        button_tag("Sign in with Persona", id: "sign_in", class: "button")
      end.html_safe
    end
  end

  def method_missing(template)
    templates = %i(
      footer_logo
      font
      links_holder
      stylesheet
      articles_list
      footer
      tagline
      top_bar
    )
    if templates.include?(template)
      switch(template)
    else
      super
    end
  end
end
