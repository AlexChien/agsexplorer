require "validators"

class Notification < ActiveRecord::Base
  include Validators

  attr_accessible :email

  validates :email, :uniqueness => true, :presence => true, :email => true
end
