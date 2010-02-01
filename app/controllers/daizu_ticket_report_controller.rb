class DaizuTicketReportController < ApplicationController
  before_filter :init
  
  def index
          
    if @assigned_to_id && @start_date && @due_date
      # get started issue.
      if @disp_end
        @all_issues =
          Issue.find_by_sql(["SELECT *, (SELECT value FROM custom_values WHERE custom_field_id = 3 AND customized_id = issues.id) AS real_start_date, (SELECT value FROM custom_values WHERE custom_field_id = 4 AND customized_id = issues.id) AS real_due_date, (SELECT SUM(hours) FROM time_entries WHERE issue_id = issues.id) AS work_hour FROM issues WHERE start_date >= :start_date AND due_date <= :due_date AND assigned_to_id = :assigned_to_id ORDER BY start_date ASC", {:start_date => @start_date, :due_date => @due_date, :assigned_to_id => @assigned_to_id}])
      else
        @all_issues =
          Issue.find_by_sql(["SELECT *, (SELECT value FROM custom_values WHERE custom_field_id = 3 AND customized_id = issues.id) AS real_start_date, (SELECT value FROM custom_values WHERE custom_field_id = 4 AND customized_id = issues.id) AS real_due_date, (SELECT SUM(hours) FROM time_entries WHERE issue_id = issues.id) AS work_hour FROM issues WHERE start_date >= :start_date AND due_date <= :due_date AND assigned_to_id = :assigned_to_id AND status_id NOT IN (SELECT id FROM issue_statuses WHERE is_closed = 1) ORDER BY start_date ASC", {:start_date => @start_date, :due_date => @due_date, :assigned_to_id => @assigned_to_id}])
      end
    end
  end

  def init
    @assigned_to_id = params[:assigned_to_id]
    @start_date = params[:start_date]
    @due_date = params[:due_date]
    @disp_end = params[:disp_end]

    @all_users =  User.find(:all, :conditions => ["status = 1"])

    if @assigned_to_id
      @target_user = User.find(:first, :conditions => ["id = ?", @assigned_to_id])
    end
  end
end
