class EstimationsController < ApplicationController

  before_action :require_user

  def initial
    backlog = Backlog.find(params[:id])
    items = Item.for_backlog_and_estimator_to_be_estimated_initially(backlog,current_user)
    if !items.empty?
      @item = items.first
      @estimated = Item.for_backlog_and_estimator_already_estimated(backlog,current_user).size
      @total = items.size + @estimated
    else
      flash[:error] = 'There are no items to be estimated initially.'
      redirect_to root_path
    end
  end

  def next
    backlog = Backlog.find(params[:id])
    items = Item.for_backlog_and_estimator_to_be_estimated_next(backlog, current_user)
    if !items.empty?
      @item = items.first
      @estimated = Item.for_backlog_and_estimator_already_estimated(backlog, current_user).size
      @total = items.size + @estimated
    else
      flash[:error] = 'There are no items to be estimated as next.'
      redirect_to root_path
    end
  end

  def reestimate
    backlog = Backlog.find(params[:id])
    items = Item.for_backlog_to_be_reestimated(backlog)
    if !items.empty?
      @total = items.size
      @estimated = get_pos-1
      if @estimated >= @total
        flash[:notice] = 'You are done with the reestimation.'
        redirect_to root_path
      else
        @item = items[@estimated]
      end
    else
      flash[:error] = 'There are no items to be re-estimated'
      redirect_to root_path
    end
  end

  def pass
    item = Item.find(params[:item_id])
    estimation = Estimation.find_by(user_id: current_user.id, item: item, value: nil) || Estimation.new(user_id: current_user.id, item: item,initial: false)
    estimation.value = params[:value]
    if estimation.save!
      flash.now[:notice] = "Your estimation of #{estimation.value} story points for item #{item.name} has been submitted."
    else
      flash.now[:error] = 'Something went wrong.'
    end
    if estimation.initial?
      redirect_to estimations_initial_backlog_path(item.backlog)
    else
      if params[:pos]
        pos = get_pos
        redirect_to estimations_reestimate_backlog_path(item.backlog,pos: pos+1)
      else
        redirect_to estimations_next_backlog_path(item.backlog)
      end
    end
  end

  private

  def get_pos
    pos = params[:pos].to_i || 1
    if pos == 0
      pos = 1
    end
    pos
  end
end