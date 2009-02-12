require 'logger'
require 'time_report_detail_v_o'
require 'time_report_main_v_o'

class DaizuTimeReportController < ApplicationController
  before_filter :init

  TRACKER_SUM_STRING = "合計"
  
  def index

    if @start_date && @due_date

      # counting per tracker.
      # counting estimated_hours and time_entries and percentage.
      @results = []
      
      @projects.each do |project|
        # per project.
        mainvo = TimeReportMainVO.new()
        mainvo.project_name = project.name
        @log.debug("project.name = " + project.name)
        
        issues =
          Issue.find(:all,
            :conditions => ["start_date >= ? and due_date <= ? and project_id = ?",
              @start_date, @due_date, project.id])

        mainvo = count_per_tracker(issues, mainvo)
        mainvo = calc_percentages(mainvo)

        @results.push(mainvo)
        
      end
    end
  end

  def count_per_tracker(issues, mainvo)

    sumvo = mainvo.get_tracker(TRACKER_SUM_STRING)

    # counting per project and per tracker.
    issues.each do |issue|

      tracker_name = @trakcer_names[issue.tracker_id]
      @log.debug("tracker_name = " + tracker_name)
      detailvo = mainvo.get_tracker(tracker_name)

      # counting estimated_hours.
      detailvo.estimated_hours += issue.estimated_hours
      sumvo.estimated_hours += issue.estimated_hours

      # counting time_entries.
      time_entry = TimeEntry.find(:all, :conditions => ["issue_id = ?", issue.id])
      time_entry.each do |entry|
        detailvo.actual_performances += entry.hours
        sumvo.actual_performances += entry.hours
      end

      mainvo.put_tracker(tracker_name, detailvo)
    end

    @log.debug("sumvo.estimated_hours = " + sumvo.estimated_hours.to_s)
    @log.debug("sumvo.actual_performances = " + sumvo.actual_performances.to_s)
    
    mainvo.put_tracker(TRACKER_SUM_STRING, sumvo)
    
    return mainvo
  end
  
  def calc_percentages(mainvo)

    mainvo.trackers.each do |key, detailvo|
      if detailvo.estimated_hours != 0 && detailvo.actual_performances != 0
        detailvo.percentages =
         (detailvo.actual_performances / detailvo.estimated_hours) * 100
         detailvo.percentages = detailvo.percentages * 100
         detailvo.percentages = detailvo.percentages.round
         detailvo.percentages = detailvo.percentages / 100

         @log.debug("key = " + key)

         mainvo.put_tracker(key, detailvo)
      end
    end

    return mainvo
  end

  def init
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @start_date = params[:start_date]
    @due_date = params[:due_date]

    @projects = Project.find :all

    @trackers = Tracker.find(:all)
    @trackers.push(Tracker.new(:name => TRACKER_SUM_STRING))
    
    @trakcer_names = {}
    @trackers.each do |tracker|
      @trakcer_names[tracker.id] = tracker.name
    end
  end
end
