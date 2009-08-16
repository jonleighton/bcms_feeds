require "open-uri"
require "timeout"
require "simple-rss"

class Feed < ActiveRecord::Base
  TTL = 30.minutes
  TTL_ON_ERROR = 10.minutes
  TIMEOUT = 10 # In seconds
  
  delegate :entries, :items, :to => :parsed_contents
  
  def parsed_contents
    @parsed_contents ||= SimpleRSS.parse(contents)
  end
  
  def contents
    if expires_at.nil? || expires_at < Time.now.utc
      begin
        self.expires_at = Time.now.utc + TTL
        new_contents = remote_contents
        SimpleRSS.parse(new_contents) # Check that we can actually parse it
        write_attribute(:contents, new_contents)
        save
      rescue StandardError, Timeout::Error, SimpleRSSError => exception
        logger.error("Loading feed #{url} failed with #{exception.inspect}")
        self.expires_at = Time.now.utc + TTL_ON_ERROR
        save
      end
    else
      logger.info("Loading feed from cache: #{url}")
    end
    
    read_attribute(:contents)
  end
  
  def remote_contents
    logger.info("Loading feed from remote: #{url}")
    Timeout.timeout(TIMEOUT) { open(url).read }
  end
end
