module DaizuTimeReportHelper
  # Adds include tags for assets of the given template
  def asset_include_tags(template)
    Redmine::Plugins::redmine_daizu.assets(template).each { |asset| content_for(:header_tags) { asset_include_tag(asset) } }
  end

  private

  def asset_include_tag(asset)
    if asset =~ %r{\.js$}
      javascript_include_tag(asset, :plugin => 'redmine_daizu')
    else
      stylesheet_link_tag(asset, :plugin => 'redmine_daizu')
    end
  end
end
