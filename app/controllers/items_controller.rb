class ItemsController < ApplicationController

  def create
    backlog = Backlog.find(params[:backlog_id])
    @item = Item.new(item_params.merge(backlog: backlog))
    if @item.save
      flash[:notice] = "Item '#{@item.name}' saved successfully.'"
      redirect_to backlog_path(@item.backlog)
    else
      render 'backlogs/show'
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      flash[:notice] = "Item '#{@item.name}' updated successfully."
      redirect_to backlog_path(@item.backlog)
    else
      render 'backlogs/show'
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :backlog_id)
  end
end