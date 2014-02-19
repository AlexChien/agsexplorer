require "spec_helper"

describe Wallet do
  context "parsing" do
    describe "wallet with 1 address" do
      before(:each) do
        data = <<-EOF
278388;2014-01-03 08:24:38 UTC;t3;a3;0.01;14.56388346;343.31502403;a3
        EOF

        Donation.parse_response(data, 'btc')
        Donation.calculate_ags_reward('2014-01-03')
        Wallet.calculate_ags_sum

        @wallet = Donation.find_by_address("a3").try(:wallet)
      end

      context "1 address" do
        it "should have 1 wallet" do
          Wallet.count.should == 1
        end

        it "should have 1 donations" do
          @wallet.donations.count.should == 1
        end

        it "should have 1 addresses" do
          @wallet.addresses.size.should == 1
          @wallet.addresses.map(&:address).should == ['a3']
        end

        it "check ags_amount" do
          @wallet.ags_amount.should == (5_000 * 0.01 / 0.01 * Ags::COIN).round
        end
      end

    end

    describe "wallet with multiple addresses" do
      before do
        data = <<-EOF
278388;2014-01-03 08:24:38 UTC;t3;a3;0.01;14.56388346;343.31502403;a31
278389;2014-01-03 08:24:38 UTC;t4;a4;0.02;14.56388346;343.31502403;a31,a32,a33
278389;2014-01-03 08:24:38 UTC;t5;a32;0.02;14.56388346;343.31502403;
        EOF

        Donation.parse_response(data, 'btc')
        day1 = Date.parse('2014-01-01')
        to_date = Date.parse('2014-01-05')
        (day1..to_date).each do |date|
          Donation.calculate_ags_reward(date)
        end
        Wallet.calculate_ags_sum

        @wallet = Donation.find_by_address("a3").try(:wallet)
      end

      context "multiple addresses" do
        it "should have 1 wallet" do
          Wallet.count.should == 1
        end

        it "should have 3 donations" do
          @wallet.donations.count.should == 3
        end

        it "should have 4 addresses" do
          @wallet.addresses.size.should == 5
          @wallet.addresses.map(&:address).sort.should == ['a3', 'a31', 'a32', 'a33','a4'].sort
        end

        it "check ags_amount" do
          @wallet.ags_amount.should == (5_000 * (0.01+0.02+0.02) / (0.01+0.02+0.02) * Ags::COIN).round
        end
      end
    end

    describe "wallet with multiple addresses case 2" do
      before do
        data = <<-EOF
278388;2014-01-03 08:24:38 UTC;t3;a3;0.01;14.56388346;343.31502403;a3
278389;2014-01-03 08:24:38 UTC;t4;a4;0.02;14.56388346;343.31502403;a4
278390;2014-01-03 08:24:38 UTC;t5;a3;0.02;14.56388346;343.31502403;a4
        EOF

        Donation.parse_response(data, 'btc')
        day1 = Date.parse('2014-01-02')
        to_date = Date.parse('2014-01-04')
        (day1..to_date).each do |date|
          Donation.calculate_ags_reward(date)
        end
        Wallet.calculate_ags_sum

        @wallet = Donation.find_by_address("a3").try(:wallet)
      end

      context "multiple addresses" do
        it "should have 1 wallet" do
          Wallet.count.should == 2
        end

        it "should have 3 donations" do
          @wallet.donations.count.should == 3
        end

        it "should have 4 addresses" do
          @wallet.addresses.size.should == 2
          @wallet.addresses.map(&:address).sort.should == ['a3', 'a4'].sort
        end

        it "check ags_amount" do
          @wallet.ags_amount.should == (5_000 * (0.01+0.02+0.02) / (0.01+0.02+0.02) * Ags::COIN).round
        end
      end
    end
  end
end