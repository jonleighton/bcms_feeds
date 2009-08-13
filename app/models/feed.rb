require "open-uri"
require "timeout"

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
        write_attribute(:contents, remote_contents)
      rescue StandardError, Timeout::Error => exception
        logger.error("Loading feed #{url} failed with #{exception.inspect}")
        self.expires_at = Time.now.utc + TTL_ON_ERROR
        read_attribute(:contents)
      end
    else
      logger.info("Loading feed from cache: #{url}")
      read_attribute(:contents)
    end
  end
  
  def remote_contents
    logger.info("Loading feed from remote: #{url}")
    Timeout.timeout(TIMEOUT) { open(url).read }
  end
end
