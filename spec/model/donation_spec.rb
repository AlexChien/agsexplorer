require "spec_helper"

describe Donation do
  context "v0.5" do
    before(:each) do
      Donation.parse_response(File.open(File.join(Rails.root, 'spec/factories/btc_data_5.txt')), 'btc')
    end

    it "check total", :skip do
      # baseline data
      # {"BTC":[
      # [2013-01-01: 61.861694286294],
      # [2014-01-02: 54.312118818387],
      # [2014-01-03: 52.742818852115],
      # [2014-01-04: 69.206746369135],
      # [2014-01-05: 55.873671190435],
      # [2014-01-06: 41.049251734832]]
      #
      # "PTS":[
      # [2013-01-01,2343.9963135793],
      # [2014-01-02,2983.9877512266],
      # [2014-01-03,2679.7434171562],
      # [2014-01-04,2681.5032923108],
      # [2014-01-05,2733.9719749189],
      # [2014-01-06,2889.5240458697],
      # [2013-01-07,3050.0523216445],
      # [2014-01-08,2385.7550195996]]}

      Donation.btc.sum(:amount).should == (61.861694286294 * Ags::COIN.to_i) + (54.312118818387 * Ags::COIN.to_i)
    end
  end

  context "total" do
    before(:all) do
      Donation.parse_response(File.open(File.join(Rails.root, 'spec/factories/btc_data.txt')), 'btc')
    end

    describe "sum" do
      it "total btc donation count" do
        Donation.btc.count.should == 442
      end

      it "total btc donation amount" do
        Donation.btc.sum(:amount).should == 29399704887
      end

      it "today should be initial donated" do
        d0105 = Date.parse('2014-01-05').to_time(:utc)
        Donation.btc.by_date(d0105).first.total.should == 5587367100

        d0104 = Date.parse('2014-01-04')
        Donation.btc.by_date(d0104).first.total.should == 6920674633

        d0103 = Date.parse('2014-01-03')
        Donation.btc.by_date(d0103).first.total.should == 5274281878

        d0102 = Date.parse('2014-01-02')
        Donation.btc.by_date(d0102).first.total.should == 5431211888

        d0101 = Date.parse('2014-01-01')
        day1 = Donation.btc.by_date(d0101).first.total
        day1 += Donation.btc.date_grouping.where("time < ?", d0101).map(&:total).sum
        day1.should == 6186169388
      end
    end

    describe 'balance' do
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
        Donation.get_donations_by_address(addr2).count == 3

        donations = Donation.get_donations_by_address(addr2)
        donations.count.should == 3
        donations.sum(:amount).should == 26172100
      end

    end

    describe "calculate_ags_reward" do
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

        Donation.btc.by_date(d0104).first.total.should == 6920674633
        ags_amount = Donation.btc.where(address: normal_addr).first.ags_amount
        ags_amount.should_not == 0
        # 5.0 / 6920674633 * 5_000 * 100_000_000
        ags_amount.should == 36123645924
      end
    end

    it "today should be intial donated + new donated" do
      d0105 = Date.parse('2014-01-05').to_time(:utc)

      Factory.create(:donation, amount: 1 * Ags::COIN, time: d0105, network: 'btc')

      Donation.btc.count.should == 443
      Donation.btc.by_date(d0105).first.total.should == 5687367100
      Donation.btc.sum(:amount).should == 29499704887
    end

  end

  context "merged addresses" do
    before do
      Donation.parse_response(File.open(File.join(Rails.root, 'spec/factories/btc_data_merged_address.txt')), 'btc')
    end

    it "should have 1 member family" do
      wallet_id = Donation.find_by_address("a1").try(:wallet_id)
      Donation.where(wallet_id: wallet_id).pluck('distinct address').size.should == 1
      Donation.where(address: "a1").first.related_addresses.count.should == 0
    end

    it "should have 2 member family" do
      wallet_id = Donation.find_by_address("a3").try(:wallet_id)
      Donation.where(wallet_id: wallet_id).pluck('distinct address').size.should == 3
      Donation.where(address: "a3").first.related_addresses.should == ['a31']
    end

    it "should have 1 member family" do
      wallet_id = Donation.find_by_address("a5").try(:wallet_id)
      Donation.where(wallet_id: wallet_id).pluck('distinct address').size.should == 0
    end

  end

end