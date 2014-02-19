require "spec_helper"

describe Daily do
  before do
    Factory(:daily, network: 'btc', date:'2014-01-02', price:1, amount:100000000)
    Factory(:daily, network: 'btc', date:'2014-01-03', price:1, amount:200000000)
    Factory(:daily, network: 'btc', date:'2014-01-04', price:1, amount:300000000)
    Factory(:daily, network: 'pts', date:'2014-01-03', price:1, amount:300000000)
  end

  context "all data" do
    it "btc" do
      data = Daily.series('btc')
      data[:btc_total].should == 6 * Ags::COIN
      data[:btc_avg].should == 2 * Ags::COIN

      data[:btc].size.should == 3
      data[:btc].first.should == [DateTime.parse('2014-01-02').to_i*1000, 1]
      data[:btc].last.should == [DateTime.parse('2014-01-04').to_i*1000, 3]
    end

    it "pts" do
      data = Daily.series('pts')
      data[:pts_total].should == 3 * Ags::COIN
      data[:pts_avg].should == 3 * Ags::COIN

      data[:pts].size.should == 1
      data[:pts].first.should == [DateTime.parse('2014-01-03').to_i*1000, 3]
    end

    it "both" do
      data = Daily.series
      data[:pts_total].should == 3 * Ags::COIN
      data[:btc_total].should == 6 * Ags::COIN
    end
  end

  context "start / end date range" do
    it "start date" do
      data = Daily.series('btc', '2014-01-03')
      data[:btc_total].should == 5 * Ags::COIN
      data[:btc].size.should == 2
    end

    it "end date" do
      data = Daily.series('btc', nil, '2014-01-03')
      data[:btc_total].should == 3 * Ags::COIN
      data[:btc].size.should == 2
    end

    it "both" do
      data = Daily.series('btc', '2014-01-03', '2014-01-03')
      data[:btc_total].should == 2 * Ags::COIN
      data[:btc].size.should == 1
    end
  end
end