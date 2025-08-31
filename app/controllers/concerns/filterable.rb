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
    return tmp
  end
end
