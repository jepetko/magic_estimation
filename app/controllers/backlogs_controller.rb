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
      flash[:error] = 'Backlog could not be saved.'
      render :new
    end
  end

  private

  def backlog_params
    params.require(:backlog).permit(:name, :description)
  end

end