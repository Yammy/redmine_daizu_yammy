require 'redmine'

Redmine::Plugin.register :redmine_daizu do
  name 'Redmine Daizu plugin'
  author 'Dai Fujihara'
  description 'This is a Reporting and Statistics plugin for Redmine'
  version '0.0.1'

  menu :application_menu, :daizu, { :controller => 'daizu_main', :action => 'index' },
  :caption => '大豆', :last => true
end
