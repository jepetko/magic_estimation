class ItemsController < ApplicationController

  before_action :require_user

  def create
    @backlog = Backlog.find(params[:backlog_id])
    @item = Item.new(item_params.merge(backlog: @backlog))
    @item.creator = current_user
    if @item.save
      flash[:notice] = "Item '#{@item.name}' saved successfully."
      redirect_to backlog_path(@backlog)
    else
      flash.now[:error] = "Item '#{@item.name}' could not be created."
      render 'backlogs/show'
    end
  end

  def update
    @item = Item.find(params[:id])
    @backlog = @item.backlog
    if @item.update(item_params)
      flash[:notice] = "Item '#{@item.name}' updated successfully."
      redirect_to backlog_path(@item.backlog, item: params[:id])
    else
      flash.now[:error] = "Item '#{@item.name}' could not be updated."
      render 'backlogs/show'
    end
  end

  def assign
    item = Item.find(params[:id])
    hash = {}
    begin
      estimation = item.assign_to_initial_estimator params[:user_id]
      hash[:state] = :ok
      hash[:obj] = estimation
    rescue Exception => e
      hash[:state] = :error
      hash[:messages] = e.message
    end
    respond_to do |format|
      format.json do
        render json: hash
      end
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :backlog_id)
  end
end