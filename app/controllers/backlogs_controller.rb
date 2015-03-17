class BacklogsController < ApplicationController

  def index
    @backlogs = Backlog.all
    respond_to do |format|
      format.html
    end
  end

end