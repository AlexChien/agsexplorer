require "validators"

class Notification < ActiveRecord::Base
  include Validators

  attr_accessible :email

  validates :email, :uniqueness => true, :presence => true, :email => true

  before_save :generate_token

  def generate_token
    self.token ||= SecureRandom.hex(10)
  end
end
