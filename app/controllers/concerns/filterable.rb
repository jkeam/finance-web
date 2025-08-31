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
end
