require "spec_helper"

describe Donation do
  before do
    Donation.parse_response("btc", File.join(Rails.root, 'spec/factories/btc_data.txt'))
  end

  context "total" do
    Donation.btc.count.should == 332

    Donation.btc.by_date(Date.parse('2014-01-04')).first.total.should
  end
end