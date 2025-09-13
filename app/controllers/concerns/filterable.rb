module Filterable
  extend ActiveSupport::Concern

  def set_filter_params(params)
    @ignore_categories = %i[]
    @sigother = (params[:sigother] || '').strip == 'true'

    @startdate = nil
    if ((params[:startdate] || '').strip != '')
      @startdate = Date.strptime(params[:startdate], "%Y-%m-%d")
    end
    @endddate = nil
    if ((params[:enddate] || '').strip != '')
      @enddate = Date.strptime(params[:enddate], "%Y-%m-%d")
    end

    unless @sigother
      @ignore_categories << :category_significant_other
    end
  end

  def spending_category_by_month(transactions, category)
    tmp = transactions.where(category: category).group_by_month(:transaction_date).sum(:amount_cents)
    tmp.each do |k, v|
      tmp[k] = v / 100
    end
    tmp
  end

  def income_by_merchant_and_month(transactions, merchant)
    tmp = transactions.where(category: :category_income, merchant: merchant).group_by_month(:transaction_date).sum(:amount_cents)
    tmp.each do |k, v|
      tmp[k] = v * -1 / 100
    end
    tmp
  end
end
