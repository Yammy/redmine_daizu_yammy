class DaizuTimeReportController < ApplicationController
  before_filter :init

  def index

    if @start_date && @due_date

      # counting per tracker.
      # counting estimated_hours and time_entries and percentage.

      # results = {"tracker", [@estimated_hours, @time_entries, @percentages]}
      @results = {}
      
      @estimated_hours = {}
      @time_entries = {}
      @percentages = {}

      @projects.each do |project|
        # per project.
        all_issues =
          Issue.find(:all,
            :conditions => ["start_date >= ? and due_date <= ? and project_id = ?",
              @start_date, @due_date, project.id])

        # TODO per tracker
        
        all_issues.each do |issue|

          # counting estimated_hours.
          if @estimated_hours[project.name]
            @estimated_hours[project.name] += issue.estimated_hours
          else
            @estimated_hours[project.name] = issue.estimated_hours
          end

          # counting time_entries.
          time_entry = TimeEntry.find(:all, :conditions => ["issue_id = ?", issue.id])

          time_entry.each do |entry|
            if @time_entries[project.name]
              @time_entries[project.name] += entry.hours
            else
              @time_entries[project.name] = entry.hours
            end
          end

        end

        # calculation percentages
        if @estimated_hours[project.name] != 0 && @time_entries[project.name] != 0
          @percentages[project.name] =
            (@time_entries[project.name] / @estimated_hours[project.name]) * 100
          @percentages[project.name] = @percentages[project.name] * 100
          @percentages[project.name] = @percentages[project.name].round
          @percentages[project.name] = @percentages[project.name] / 100
        else
          @percentages[project.name] = 0
        end
        
      end
    end
  end

  def init
    @start_date = params[:start_date]
    @due_date = params[:due_date]

    @projects = Project.find :all

    @trackers = Tracker.find(:all)
  end
end
