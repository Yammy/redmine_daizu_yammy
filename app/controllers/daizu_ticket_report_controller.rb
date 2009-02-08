class DaizuTicketReportController < ApplicationController
  before_filter :init
  
  def index
          
    if @assigned_to_id && @start_date && @due_date
      # get issues
      
      # get started issue.
      @all_issues =
        Issue.find(:all,
          :conditions => ["start_date >= ? and due_date <= ? and assigned_to_id = ?",
            @start_date, @due_date, @assigned_to_id],
          :order => "start_date")
    end
  end

  def init
    @assigned_to_id = params[:assigned_to_id]
    @start_date = params[:start_date]
    @due_date = params[:due_date]

    @all_users =  User.find(:all, :conditions => ["status = 1"])

    if @assigned_to_id
      @target_user = User.find(:first, :conditions => ["id = ?", @assigned_to_id])
    end
  end
end
