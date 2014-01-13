namespace :email do
  desc "daily notification"
  task :daily => :environment do |t, args|
    @data = {
      daily_data:          Donation.daily,
      today:               Donation.by_date,
      today_btc_donations: Donation.btc.today_donations,
      today_pts_donations: Donation.pts.today_donations,
      today_btc_donated:   Donation.today_donated(:btc),
      today_pts_donated:   Donation.today_donated(:pts),
      btc_current_price:   Donation.current_price(:btc),
      pts_current_price:   Donation.current_price(:pts)
    }

    rate = Ticker.where(market: 'bter', pair: 'pts_btc').last.try(:last)
    @data[:btce] = @data[:btc_current_price] * rate / @data[:pts_current_price]
    @data[:ptse] = 1 / @data[:btce]

    Notification.find_each do |n|
      puts "send > #{n.email}"
      NotificationMailer.daily(n.email, @data).deliver
      sleep 2
    end
  end
end