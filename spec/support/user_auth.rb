module UserAuth
  def sign_in
    visit "/"
    page.find(".list-container").hover

    case ENV["OMNIAUTH"]
    when "cas"
      click_link "Sign in with PLOS ID"
    when "orcid"
      click_link "Sign in with ORCID"
    when "github"
      click_link "Sign in with Github"
    else
      click_button "Sign in with Persona"
    end
  end

  def sign_out
    visit "/"
    page.find(".list-container").hover
    click_link "Sign Out"
  end
end

RSpec.configure do |config|
  config.include UserAuth, type: :feature
end
