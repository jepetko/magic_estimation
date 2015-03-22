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
    estimation = Estimation.where.not(user_id: params[:user_id], value: nil).where(item: item, initial: true).first
    hash = {}
    if !estimation.nil?
      hash[:state] = :error
      hash[:messages] = ["This item cannot be re-assigned because its already estimated initially with #{estimation.value} points."]
    else
      begin
        ActiveRecord::Base.transaction do
          own_estimation = Estimation.find_by(user_id: params[:user_id], item: item) || Estimation.new(user_id: params[:user_id], item: item)
          own_estimation.initial = true
          if own_estimation.save
            hash[:state] = :ok
            hash[:obj] = own_estimation
          else
            hash[:state] = :error
            hash[:messages] = own_estimation.errors.full_messages
          end
          # set initial = false for the previous assignees
          Estimation.where.not(user_id: params[:user_id]).where(item: item).update_all(initial: false)
        end
      rescue Exception => e
        hash[:state] = :error
        hash[:messages] = [e.message]
      end
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