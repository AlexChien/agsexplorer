# require "spec_helper"
#
# describe Notification do
#   describe "daily" do
#     let(:mail) { NotificationMailer.daily(Factory(:notification), {}) }
#
#     it "renders the headers" do
#       mail.subject.should eq("Daily")
#       mail.to.should eq(["to@example.org"])
#       mail.from.should eq(["from@example.com"])
#     end
#
#     it "renders the body" do
#       mail.body.encoded.should match("Hi")
#     end
#   end
#
# end
