# # -*- encoding : utf-8 -*-
# module AuthenticationHelpers
#   include Warden::Test::Helpers
#
#   # request test helper
#   def sign_in_as!(user)
#     visit '/users/login'
#     fill_in 'user_login', :with => user.username
#     fill_in 'user_password', :with => user.password
#     click_button 'login'
#   end
# end
#
# RSpec.configure do |c|
#   c.include AuthenticationHelpers, :type => :request
#   c.include Devise::TestHelpers, :type => :controller
# end
