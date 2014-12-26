require "rails_helper"

describe "user sessions", :type => :feature do
  it "signs in as Persona user", js: true do
    sign_in
    expect(page).to have_content "joe@example.com"
  end

  # it "sign in error as Persona user", js: true do
  #   puts ENV["OMNIAUTH"]
  #   OmniAuth.config.mock_auth[:persona] = :invalid_credentials
  #   sign_in
  #   expect(page).to have_content "Your Article List"
  #   expect(page).to have_content "Could not authenticate you from Persona because \"invalid credentials\""
  # end

  # it "signs in as CAS user", js: true do
  #   ENV["OMNIAUTH"] = "cas"
  #   puts ENV["OMNIAUTH"]
  #   sign_in
  #   expect(page).to have_content "joe@example.com"
  # end

  # it "signs in as ORCID user", js: true do
  #   ENV["OMNIAUTH"] = "orcid"
  #   sign_in
  #   expect(page).to have_content "joe@example.com"
  # end

  # it "signs in as Github user", js: true do
  #   ENV["OMNIAUTH"] = "github"
  #   sign_in
  #   expect(page).to have_content "joe@example.com"
  # end

  it "signs out as user", js: true do
    sign_in
    sign_out
    expect(page).to have_content "Your Article List"
  end
end
