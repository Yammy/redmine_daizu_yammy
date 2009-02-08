class DaizuTicketReportController < ApplicationController
  before_filter :get_param, :get_all_user, :get_target_usr
  
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

  def get_param
    @assigned_to_id = params[:assigned_to_id]
    @start_date = params[:start_date]
    @due_date = params[:due_date]
  end
  
  def get_all_user
    @all_users =  User.find(:all, :conditions => ["status = 1"])
  end

  def get_target_usr
    if @assigned_to_id
      @target_user = User.find(:first, :conditions => ["id = ?", @assigned_to_id])
    end
  end
end
