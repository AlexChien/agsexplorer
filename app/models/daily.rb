class Daily < ActiveRecord::Base
  attr_accessible :amount, :date, :network, :price, :volume

  scope :btc, where(network: :btc)
  scope :pts, where(network: :pts)
  scope :asc, order("date asc")

  # Get data series for charts
  # @param network [string|array]: network to fetch
  # @param sd [String]: start date
  # @param ed [String]: end date
  #
  # @example:
  # Daily.series([btc,pts], '2014-01-03', '2014-01-04')
  #
  def self.series(network = nil, start_date = nil, end_date = nil)
    networks = %w(btc pts)
    if !network.nil? && network.is_a?(String)
      network = [network]
      networks = networks & network.to_a.collect{ |n| n.downcase.to_s }
    end

    data = {}

    networks.each do |network|
      # initial data strucutre
      data[:"#{network}_total"] = 0
      data[:"#{network}_avg"] = 0
      data[:"#{network}"] = []

      d = Daily.send(network).scoped
      d = d.where('date >= ?', Date.parse(start_date)) unless start_date.nil?
      d = d.where('date < ?', Date.parse(end_date).tomorrow) unless end_date.nil?
      d = d.order('date asc').all
      data[network.to_sym] = d.collect{ |record|
        data[:"#{network}_total"] += record[:amount]
        [DateTime.parse(record[:date].to_s(:db)).to_i * 1000, (record[:amount] / Ags::COIN.to_f).round(8)]
      }

      data[:"#{network}_avg"] = data[:"#{network}_total"] / data[network.to_sym].size
    end

    data
  end
end
