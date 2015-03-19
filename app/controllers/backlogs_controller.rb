class BacklogsController < ApplicationController

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
    if @backlog.save
      flash[:notice] = "Backlog #{@backlog.name} saved."
      redirect_to backlogs_path
    else
      render :new
    end
  end

  def show
    @backlog = Backlog.find(params[:id])
  end

  def edit
    @backlog = Backlog.find(params[:id])
  end

  def update
    @backlog = Backlog.find(params[:id])
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

  def backlog_params
    params.require(:backlog).permit(:name, :description)
  end

end