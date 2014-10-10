module BalancesHelper
  def ags_amount_by_address(donations, address)
    donations.select{ |d| d.address == address && d.time < Ags::END_DATE }.map(&:ags_amount).sum
  end

  def donation_amount_by_address(donations, address)
    donations.select{ |d| d.address == address && d.time < Ags::END_DATE }.map(&:amount).sum
  end
end
