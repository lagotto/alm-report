class User < ActiveRecord::Base
  has_and_belongs_to_many :reports

  before_save :ensure_authentication_token

  devise :registerable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:persona, :cas, :github, :orcid]

  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true

  def self.from_omniauth(auth)
    Rails.logger.debug auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end

  # fetch additional user information for cas strategy
  def self.fetch_raw_info(uid)
    conn = Faraday.new(url: ENV["CAS_INFO_URL"]) do |faraday|
             faraday.request  :url_encoded
             faraday.response :logger
             faraday.response :json
             faraday.adapter  Faraday.default_adapter
           end
    profile = conn.get("/#{uid}").body || {}
    { name: profile.fetch("realName", uid),
      email: profile.fetch("email", nil) }
  end

  protected

  # Don't require email or password, as we also use OAuth
  def email_required?
    false
  end

  def password_required?
    false
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
