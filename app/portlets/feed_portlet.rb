class FeedPortlet < Portlet
  handler "erb"
  
  def render
    raise ArgumentError, "No feed URL specified" if self.url.blank?
    @feed = Feed.find_or_create_by_url(self.url).parsed_contents
    instance_eval(self.code) unless self.code.blank?
  end
end
