# To change this template, choose Tools | Templates
# and open the template in the editor.

class TimeReportMainVO

  TRACKER_SUM_STRING = "合計"

  def initialize
    @project_name = ""

    #FIXME
    @trackers = Hash.new()
    all_trackers = Tracker.find(:all)
    all_trackers.each do |tracker|
      @trackers[tracker.name] = TimeReportDetailVO.new()
    end
    @trackers[TRACKER_SUM_STRING] = TimeReportDetailVO.new()
  end

  def get_tracker(name)
    return trackers[name]
  end

  def put_tracker(name, value)
    trackers[name] = value
  end

  attr_accessor :project_name, :trackers
end
