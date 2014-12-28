require 'rails_helper'

RSpec.describe User, :type => :model, vcr: true do

  subject { User.new(name: "Joe Smith", uid: "12345", provider: "cas") }

  describe "class methods" do
    it "from_omniauth" do
      auth = OmniAuth.config.mock_auth[:default]
      user = User.from_omniauth(auth)
      expect(user.name).to eq("Joe Smith")
    end

    it "get_profile" do
      profile = User.get_profile(subject.uid)
      expect(profile["realName"]).to eq("Joe Smith")
    end

    it "get_profile no uid" do
      profile = User.get_profile(nil)
      expect(profile).to eq("error" => "no uid provided")
      expect(profile["realName"]).to be_nil
    end

    it "get_profile profile not found" do
      profile = User.get_profile("123")
      expect(profile).to eq("error" => "757: unexpected token at 'UserProfile not found at authId=123\n'")
      expect(profile["realName"]).to be_nil
    end

    it "fetch_raw_info" do
      info = User.fetch_raw_info(subject.uid)
      expect(info).to eq(name: "Joe Smith", email: "joe@example.com", nickname: "jsmith", first_name: "Joe", last_name: "Smith")
    end
  end

  it "requires a name" do
    subject.name = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to eq(["can't be blank"])
  end

  it "requires an authentication token" do
    subject.save
    expect(subject.authentication_token).not_to be_nil
  end
end
