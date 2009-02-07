class DaizuMainController < ApplicationController

  def index
    @projects = Project.find :all,
                          :conditions => Project.visible_by(User.current),
                          :include => :parent
  end
  
end
