class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :authentication_keys => [:phone]
  
  include DeviseTokenAuth::Concerns::User

  attr_accessor :login

  validates :phone,
    :presence => true,
    :uniqueness => {
      :case_sensitive => false
    }, format: { with: /\A1\d{10}\z/ }

  def validate_username
    if User.where(email: phone).exists?
      errors.add(:username, :invalid)
    end
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.phone || self.email
  end


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(phone) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    # elsif conditions.has_key?(:phone) || conditions.has_key?(:email)
    #   where(conditions.to_h).first
    # end
    else
      if conditions[:phone].nil?
        where(conditions).first
      else
        where(phone: conditions[:phone]).first
      end
    end
  end


end

