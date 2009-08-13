require File.dirname(__FILE__) + "/../test_helper"

class FeedTest < ActiveSupport::TestCase
  def setup
    @feed = Feed.new(:url => "http://example.com/blog.rss")
    @contents = "<feed>Some feed</feed>"
    
    now = Time.now
    Time.stubs(:now).returns(now) # Freeze time
    
    # small timeout for testing purposes
    Feed.send(:remove_const, :TIMEOUT)
    Feed.const_set(:TIMEOUT, 1)
  end

  def test_remote_contents
    @feed.expects(:open).with("http://example.com/blog.rss").returns(stub(:read => @contents))
    assert_equal @contents, @feed.remote_contents
  end
  
  def test_remote_contents_timeout
    def @feed.open(url)
      sleep(2)
      stubs(:read => "bla")
    end
    
    assert_raise(Timeout::Error) { @feed.remote_contents }
  end
  
  def test_contents_no_expiry
    @feed.expires_at = nil
    @feed.stubs(:remote_contents).returns(@contents)
    
    assert_equal @contents, @feed.contents
    assert_equal @contents, @feed.read_attribute(:contents)
    assert_equal Time.now.utc + Feed::TTL, @feed.expires_at
  end
  
  def test_contents_expiry_in_past
    @feed.expires_at = Time.now - 1.hour
    @feed.stubs(:remote_contents).returns(@contents)
    
    assert_equal @contents, @feed.contents
    assert_equal @contents, @feed.read_attribute(:contents)
    assert_equal Time.now.utc + Feed::TTL, @feed.expires_at
  end
  
  def test_contents_expiry_in_future
    @feed.expires_at = Time.now + 1.hour
    @feed.write_attribute(:contents, @contents)
    
    assert_equal @contents, @feed.contents
  end
  
  def test_contents_expiry_in_past_with_error_getting_remote_contents
    [StandardError, Timeout::Error].each do |exception|
      @feed.expires_at = Time.now - 1.hour
      @feed.stubs(:remote_contents).raises(exception)
      @feed.write_attribute(:contents, @contents)
      
      assert_equal @contents, @feed.contents
      assert_equal Time.now.utc + Feed::TTL_ON_ERROR, @feed.expires_at
    end
  end
end
