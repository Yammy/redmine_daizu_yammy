class DaizuTicketReportController < ApplicationController


  def index
    @users =  User.find :all
  end

  def daily
  end

  def weekly
  end

  def monthly
  end

end
