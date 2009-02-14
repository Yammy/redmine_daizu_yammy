require 'logger'
require 'time_report_detail_v_o'
require 'time_report_main_v_o'

class DaizuTimeReportController < ApplicationController
  before_filter :init

  TRACKER_SUM_STRING = "合計"
  
  def index

    if @project_id && @start_date && @due_date

      # counting per tracker.
      # counting estimated_hours and time_entries and percentages.
      @results = []

      if @project_id == "all"
        @projects.each do |project|
          calc_per_project(project)
        end

        all_sumvo = calc_allsum(@results)
        @results.push(all_sumvo)
      else
        project = Project.find(:first, :conditions => ["id = ?", @project_id])
        calc_per_project(project)
      end
      
    end
  end

  def calc_per_project(project)
    # per project.
    mainvo = TimeReportMainVO.new()
    mainvo.project_name = project.name

    issues =
      Issue.find(:all,
        :conditions => ["start_date >= ? and due_date <= ? and project_id = ?",
          @start_date, @due_date, project.id])

    mainvo = count_per_tracker(issues, mainvo)
    mainvo = calc_percentages(mainvo)

    @results.push(mainvo)
  end

  def count_per_tracker(issues, mainvo)

    sumvo = mainvo.get_tracker(TRACKER_SUM_STRING)

    # counting per project and per tracker.
    issues.each do |issue|

      tracker_name = @trakcer_names[issue.tracker_id]
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
    
    mainvo.put_tracker(TRACKER_SUM_STRING, sumvo)
    
    return mainvo
  end
  
  def calc_percentages(mainvo)

    mainvo.trackers.each do |key, detailvo|
      detailvo.percentages =
        calc_percentage(detailvo.estimated_hours, detailvo.actual_performances)
      mainvo.put_tracker(key, detailvo)
    end

    return mainvo
  end

  def calc_percentage(estimated_hours, actual_performances)
    if estimated_hours != 0 && actual_performances != 0
      percentage =
       (actual_performances / estimated_hours) * 100
       percentage = percentage * 100
       percentage = percentage.round
       percentage = percentage / 100
       return percentage
    else
      return 0.0
    end
  end
  
  def calc_allsum(results)

    sumvo = TimeReportMainVO.new()
    sumvo.project_name = TRACKER_SUM_STRING
    
    results.each do |result|
      result.trackers.each do |tracker_name, detailvo|
        detailsumvo = sumvo.get_tracker(tracker_name)
        detailsumvo.estimated_hours += detailvo.estimated_hours
        detailsumvo.actual_performances += detailvo.actual_performances
        sumvo.put_tracker(tracker_name, detailsumvo)
      end
    end

    sumvo.trackers.each do |tracker_name, tracker|
      detailsumvo = sumvo.get_tracker(tracker_name)
      detailsumvo.percentages =
        calc_percentage(detailsumvo.estimated_hours, detailsumvo.actual_performances)
    end

    return sumvo
  end

  def init
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @project_id = params[:project_id]
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
