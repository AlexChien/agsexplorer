require "spec_helper"

describe Donation do
  context "total" do
    before do
      Donation.parse_response(File.open(File.join(Rails.root, 'spec/factories/btc_data.txt')), 'btc')
    end

    it "total btc donation count" do
      Donation.btc.count.should == 445
    end

    it "total btc donation amount" do
      Donation.btc.sum(:amount).should == 25636669281
    end

    it "today should be initial donated" do
      d0105 = Date.parse('2014-01-05').to_time(:utc)
      Donation.btc.by_date(d0105).first.total.should == 2176732693

      d0104 = Date.parse('2014-01-04')
      Donation.btc.by_date(d0104).first.total.should == 6820674634

      d0103 = Date.parse('2014-01-03')
      Donation.btc.by_date(d0103).first.total.should == 5269281880

      d0102 = Date.parse('2014-01-02')
      Donation.btc.by_date(d0102).first.total.should == 5311211888

      d0101 = Date.parse('2014-01-01')
      day1 = Donation.btc.by_date(d0101).first.total
      day1 += Donation.btc.date_grouping.where("time < ?", d0101).map(&:total).sum
      day1.should == 6058768186
    end

    context 'balance' do
      # single donation
      let(:addr1){ '1B2j7DcFBC7Bp3zhMDMSC1FYLeRS9V3NVo' }
      # multiple donations
      let(:addr2){ '1aQURHDuebbJEbpBQxkWRAdW8TX8ofU17' }

      it "get_balance" do
        Donation.get_balance(addr1).should == 10000000

        Donation.get_balance(addr2).should == 26172100
      end

      it 'get_donations_by_addr' do
        Donation.get_donations_by_address(addr1).count == 1
        Donation.get_donations_by_address(addr2).count == 2

        donations = Donation.get_donations_by_address(addr2)
        donations.count.should == 3
        donations.sum(:amount).should == 26172100
      end

    end

    context "calculate_ags_reward" do
      let(:preday1_addr) { '1CXEo9yJwU5V3d6FmGyt6ni8KFE26i6t8i' }
      let(:day1_addr) { '1M9zLJveSTkoSYz1h5CWHUgo4sHijvPvjX' }
      let(:normal_addr) { '12tZFZL2Fcw5d5NyvHG35oK6tLwEjCfNhN' }

      it "preday1" do
        preday = Date.parse('2013-12-25').to_time(:utc)
        Donation.calculate_ags_reward(preday, ['btc'])

        ags_amount = Donation.btc.where(address: preday1_addr).first.ags_amount
        ags_amount.should_not == 0
        #1237875385 #15000000.to_f / 6058768186 * 5000 * 100000000
        ags_amount.should == 1237875385
      end

      it "day1" do
        preday = Date.parse('2014-01-01').to_time(:utc)
        Donation.calculate_ags_reward(preday, ['btc'])

        ags_amount = Donation.btc.where(address: day1_addr).first.ags_amount
        ags_amount.should_not == 0
        #82525026 #1000000.to_f / 6058768186 * 5000 * 100000000
        ags_amount.should == 82525026
      end

      it "normal day" do
        d0104 = Date.parse('2014-01-04').to_time(:utc)
        Donation.calculate_ags_reward(d0104, ['btc'])

        Donation.btc.by_date(d0104).first.total.should == 6820674634
        ags_amount = Donation.btc.where(address: normal_addr).first.ags_amount
        ags_amount.should_not == 0
        #366.53265756702274 #500000000.to_f / 6820674634 * 5000 * 100000000
        ags_amount.should == 36653265757
      end
    end

    it "today should be intial donated + new donated" do
      d0105 = Date.parse('2014-01-05').to_time(:utc)

      Factory.create(:donation, amount: 1 * Ags::COIN, time: d0105, network: 'btc')

      Donation.btc.count.should == 446
      Donation.btc.by_date(d0105).first.total.should == 2276732693
      Donation.btc.sum(:amount).should == 25736669281
    end

  end

  context "merged addresses" do
    before do
      Donation.parse_response(File.open(File.join(Rails.root, 'spec/factories/btc_data_merged_address.txt')), 'btc')
    end

    let(:addr21) { "14Ntbt1fRcAzreQUYtmPSJynsyuMKFxFmw" }
    let(:addr22) { "1HRomwYh98owAbe7SYtA45Wki73KWpyt7E" }
    let(:addr1) { "1M16SzSwY9RXpxadEyQ6vdjnNUntk4iogu" }

    it "should have 2 member family" do
      wallet_id = Donation.find_by_address(addr21).try(:wallet_id)
      Donation.where(wallet_id: wallet_id).pluck('distinct address').size.should == 2
    end

    it "should have 2 member family" do
      wallet_id = Donation.find_by_address(addr22).try(:wallet_id)
      Donation.where(wallet_id: wallet_id).pluck('distinct address').size.should == 2
    end

    it "should have 1 member family", :focus do
      wallet_id = Donation.find_by_address(addr1).try(:wallet_id)
      Donation.where(wallet_id: wallet_id).pluck('distinct address').size.should == 1
    end


  end

end