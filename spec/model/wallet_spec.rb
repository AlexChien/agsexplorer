require "spec_helper"

describe Wallet do
  context "parsing" do
    before do
      Donation.parse_response(File.open(File.join(Rails.root, 'spec/factories/btc_data_merged_address.txt')), 'btc')

      day1 = Date.parse('2014-01-01')
      to_date = Date.parse('2014-01-05')
      (day1..to_date).each do |date|
        Donation.calculate_ags_reward(date)
      end
      Wallet.calculate_ags_sum
    end

    let(:addr21) { "14Ntbt1fRcAzreQUYtmPSJynsyuMKFxFmw" }
    let(:addr22) { "1HRomwYh98owAbe7SYtA45Wki73KWpyt7E" }
    let(:addr1) { "1M16SzSwY9RXpxadEyQ6vdjnNUntk4iogu" }

    it "wallet records" do
      Wallet.count.should == 3
    end

    context "wallet with 2 addresses" do
      let(:wallet) { Donation.find_by_address(addr21).try(:wallet) }

      it "should have 3 donations" do
        wallet.donations.count.should == 3
      end

      it "check ags_amount" do
        wallet.ags_amount.should == (5_000 * (1 + (0.1355 + 0.0145) / (0.1355 + 0.0145 + 0.21234)) * Ags::COIN).round
      end
    end

    context "wallet with 1 address" do
      let(:wallet) { Donation.find_by_address(addr1).try(:wallet) }

      it "should have 1 donations" do
        wallet.donations.count.should == 1
      end

      it "check ags_amount" do
        wallet.ags_amount.should == (5_000 * 0.21234 / (0.1355 + 0.0145 + 0.21234) * Ags::COIN).round
      end
    end
  end
end