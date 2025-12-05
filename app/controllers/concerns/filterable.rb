module Filterable
  extend ActiveSupport::Concern

  def set_filter_params()
    @startdate = nil
    if ((params[:startdate] || '').strip != '')
      @startdate = Date.strptime(params[:startdate], "%Y-%m-%d")
    end
    @startdate ||= Date.current.months_ago(12).beginning_of_month

    @endddate = nil
    if ((params[:enddate] || '').strip != '')
      @enddate = Date.strptime(params[:enddate], "%Y-%m-%d")
    end
    @enddate ||= Date.current.beginning_of_month
  end

  def income_by_merchant_and_month(transactions, startdate, enddate, merchant)
    tmp = transactions
      .where(merchant: merchant)
      .group_by_month(:transaction_date, range: startdate..enddate, expand_range: true)
      .sum(:amount_cents)
    tmp.each do |k, v|
      tmp[k] = v * -1 / 100
    end
    tmp
  end
end
