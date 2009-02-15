# To change this template, choose Tools | Templates
# and open the template in the editor.

class BugReportMainVO

  TRACKER_SUM_STRING = "合計"
  CUSTOM_FIELD_ID = 1
  
  def initialize
    @project_name = ""

    #FIXME
    @values = Hash.new()
    custom_values = CustomValue.find(:all, :conditions => ["custom_field_id = ?", CUSTOM_FIELD_ID])
    custom_values.each do |value|
      if !@values[value.value]
        @values[value.value] = 0
      end
    end
    @values[TRACKER_SUM_STRING] = 0
  end

  def get_value(name)
    return @values[name]
  end

  def put_value(name, value)
    @values[name] = value
  end

  attr_accessor :project_name, :values
end
