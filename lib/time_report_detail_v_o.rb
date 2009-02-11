# To change this template, choose Tools | Templates
# and open the template in the editor.

class TimeReportDetailVO
  def initialize
    @estimated_hours = 0.0
    @actual_performances = 0.0
    @percentages = 0.0
  end

  attr_accessor :estimated_hours, :actual_performances, :percentages
end
