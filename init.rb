require 'redmine'

Redmine::Plugin.register :redmine_daizu do
  name 'Redmine Daizu plugin'
  author 'Dai Fujihara'
  description 'This is a Reporting and Statistics plugin for Redmine'
  version '0.3.0'

  menu :application_menu, :redmine_daizu, { :controller => 'daizu_main', :action => 'index' },
  :caption => :plugin_name, :last => true
end
