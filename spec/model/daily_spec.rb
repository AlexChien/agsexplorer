require "spec_helper"

describe Daily do
  before do
    Factory(:daily, network: 'btc', date:'2014-01-02', price:1, amount:1)
    Factory(:daily, network: 'btc', date:'2014-01-03', price:1, amount:2)
    Factory(:daily, network: 'btc', date:'2014-01-04', price:1, amount:3)
    Factory(:daily, network: 'pts', date:'2014-01-03', price:1, amount:3)
  end

  context "all data" do
    it "btc" do
      data = Daily.series('btc')
      data[:btc_total].should == 6
      data[:btc_avg].should == 2

      data[:btc].size.should == 3
      data[:btc].first.sort.should == {"date" => Date.parse('2014-01-02'), "amount" => 1}.sort
      data[:btc].last.sort.should == {"date" => Date.parse('2014-01-04'), "amount" => 3}.sort
    end

    it "pts" do
      data = Daily.series('pts')
      data[:pts_total].should == 3
      data[:pts_avg].should == 3

      data[:pts].size.should == 1
      data[:pts].first.sort.should == {"date" => Date.parse('2014-01-03'), "amount" => 3}.sort
    end

    it "both" do
      data = Daily.series
      data[:pts_total].should == 3
      data[:btc_total].should == 6
    end
  end

  context "start / end date range" do
    it "start date" do
      data = Daily.series('btc', '2014-01-03')
      data[:btc_total].should == 5
      data[:btc].size.should == 2
    end

    it "end date" do
      data = Daily.series('btc', nil, '2014-01-03')
      data[:btc_total].should == 3
      data[:btc].size.should == 2
    end

    it "both" do
      data = Daily.series('btc', '2014-01-03', '2014-01-03')
      data[:btc_total].should == 2
      data[:btc].size.should == 1
    end
  end
end