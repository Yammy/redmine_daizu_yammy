require 'date'
require 'time_report_detail_v_o'
require 'bug_report_main_v_o'

class DaizuBugReportController < ApplicationController
  before_filter :init

  TRACKER_SUM_STRING = "合計"
  BUG_TRACKER_NAME = "バグ"
  CUSTOM_FIELD_ID = 1
  
  def index
    if @project_id && @start_date && @due_date
      @results = []
      @before_results = []
      
      if @project_id == "all"
        @projects.each do |project|
          issues = get_issues(project.id, @bug_tracker_id, @start_date, @due_date)
          @results.push(calc_per_project(project, issues))
        end

        all_sumvo = calc_allsum(@results)
        @results.push(all_sumvo)
      else
        project = Project.find(:first, :conditions => ["id = ?", @project_id])
        issues = get_issues(project.id, @bug_tracker_id, @start_date, @due_date)
        @results.push(calc_per_project(project, issues))

        # before period.
        issues = get_before_issues(project.id, @bug_tracker_id, @start_date, @due_date)
        @before_results.push(calc_per_project(project, issues))

        # before before period.
        issues = get_before_before_issues(project.id, @bug_tracker_id, @start_date, @due_date)
        @before_results.push(calc_per_project(project, issues))
      end
    end
  end

  def calc_per_project(project, issues)
    # per project.
    mainvo = BugReportMainVO.new()
    mainvo.project_name = project.name

    mainvo = count_per_value(issues, mainvo)

    return mainvo
  end

  def count_per_value(issues, mainvo)

    sum = mainvo.get_value(TRACKER_SUM_STRING)
    
    # counting per project and per value.
    issues.each do |issue|

      custom_value = CustomValue.find(:first, :conditions => ["customized_id = ?", issue.id])
      if custom_value
        value = mainvo.get_value(custom_value.value)
        value += 1
        sum += 1
        mainvo.put_value(custom_value.value, value)
      end
      
    end

    mainvo.put_value(TRACKER_SUM_STRING, sum)

    return mainvo
  end

  def calc_allsum(results)

    sumvo = BugReportMainVO.new()
    sumvo.project_name = TRACKER_SUM_STRING

    results.each do |result|
      result.values.each do |key, value|
        sum = sumvo.get_value(key)
        sum = sum + value
        sumvo.put_value(key, sum)
      end
    end

    return sumvo
  end

  def get_issues(project_id, bug_tracker_id, start_date, due_date)
    return Issue.find(:all,
        :conditions => ["project_id = ? and tracker_id = ? and start_date >= ? and due_date <= ?",
          project_id, bug_tracker_id, start_date, due_date])
  end

    def get_before_issues(project_id, bug_tracker_id, start_date, due_date)
    s = Date.strptime(start_date, "%Y-%m-%d")
    d = Date.strptime(due_date, "%Y-%m-%d")

    before_start = s - (d - s)
    before_end = s - 1

    return get_issues(project_id, bug_tracker_id, before_start, before_end)
  end

  def get_before_before_issues(project_id, bug_tracker_id, start_date, due_date)
    s = Date.strptime(start_date, "%Y-%m-%d")
    d = Date.strptime(due_date, "%Y-%m-%d")

    before_start = s - (d - s) - (d - s)
    before_end = s - (d - s)

    return get_issues(project_id, bug_tracker_id, before_start, before_end)
  end
  
  def init
    @project_id = params[:project_id]
    @start_date = params[:start_date]
    @due_date = params[:due_date]

    @projects = Project.find :all
    @custom_values = CustomValue.find(:all, :conditions => ["custom_field_id = ?", CUSTOM_FIELD_ID])
    @values = Hash.new()
    @custom_values.each do |value|
      if !@values[value.value]
        @values[value.value] = 0
      end
    end
    @values[TRACKER_SUM_STRING] = 0
    
    @bug_tracker = Tracker.find(:first, :conditions => ["name = ?", BUG_TRACKER_NAME])
    @bug_tracker_id = @bug_tracker.id
  end
end
