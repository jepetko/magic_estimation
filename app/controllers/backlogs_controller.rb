class BacklogsController < ApplicationController

  before_action :require_user, except: [:index]
  before_action :set_backlog, only: [:show, :edit, :update]

  def index
    @backlogs = Backlog.all
    respond_to do |format|
      format.html
    end
  end

  def new
    @backlog = Backlog.new
  end

  def create
    @backlog = Backlog.new(backlog_params)
    @backlog.creator = current_user
    if @backlog.save
      flash[:notice] = "Backlog #{@backlog.name} saved."
      redirect_to backlogs_path
    else
      render :new
    end
  end

  def show
    if params[:item]
      @item = Item.find(params[:item])
    else
      @item = Item.new
      @item.backlog = @backlog
    end
  end

  def edit
  end

  def update
    if @backlog.update(backlog_params)
      flash[:notice] = 'Backlog has been updated successfully.'
      redirect_to backlog_path(@backlog)
    else
      render :edit
    end
  end

  def destroy
    if Backlog.destroy(params[:id])
      flash[:notice] = 'Backlog has been destroyed.'
      redirect_to backlogs_path
    end
  end

  private

  def set_backlog
    @backlog = Backlog.find(params[:id])
  end

  def backlog_params
    params.require(:backlog).permit(:name, :description)
  end

end