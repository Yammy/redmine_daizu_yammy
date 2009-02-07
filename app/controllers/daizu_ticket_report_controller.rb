class DaizuTicketReportController < ApplicationController
  before_filter :get_all_user
  
  def index
    assigned_to_id = params[:assigned_to_id]
    start_date = params[:start_date]
    due_date = params[:due_date]
          
    if assigned_to_id && start_date && due_date
      # get issues
      projects = Project.find :all,
                        :conditions => Project.visible_by(User.current)

      @all_issues = Hash.new("0")
      projects.each do |project|
        @all_issues[project.name] = project.issues
      end
    end
  end

  def get_all_user
    @users =  User.find :all
  end
end
