class EstimationsController < ApplicationController

  before_action :require_user

  def initial
    backlog = Backlog.find(params[:id])
    items = Item.for_backlog_and_estimator_to_be_estimated_initially(backlog,current_user)
    if !items.empty?
      @item = items.first
      @total = Item.for_backlog_and_estimator(backlog,current_user).size
      @estimated = Item.for_backlog_and_estimator_already_estimated(backlog,current_user).size
    else
      flash[:error] = 'There are no items to be estimated initially.'
      redirect_to(:back)
    end
  end

  def next
    params
  end
end