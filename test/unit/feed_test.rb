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
  
  test "remote_contents should fetch the feed" do
    @feed.expects(:open).with("http://example.com/blog.rss").returns(stub(:read => @contents))
    assert_equal @contents, @feed.remote_contents
  end
  
  test "remote_contents should raise a Timeout::Error if fetching the feed takes longer then Feed::TIMEOUT" do
    def @feed.open(url)
      sleep(2)
      stubs(:read => "bla")
    end
    
    assert_raise(Timeout::Error) { @feed.remote_contents }
  end
  
  test "contents with no expiry should return the remote contents and save it" do
    @feed.expires_at = nil
    @feed.stubs(:remote_contents).returns(@contents)
    
    assert_equal @contents, @feed.contents
    assert_equal @contents, @feed.read_attribute(:contents)
    assert_equal Time.now.utc + Feed::TTL, @feed.expires_at
  end
  
  test "contents with an expiry in the past return the remote contents and save it" do
    @feed.expires_at = Time.now - 1.hour
    @feed.stubs(:remote_contents).returns(@contents)
    
    assert_equal @contents, @feed.contents
    assert_equal @contents, @feed.read_attribute(:contents)
    assert_equal Time.now.utc + Feed::TTL, @feed.expires_at
  end
  
  test "contents with the expiry in the future should return the cached contents" do
    @feed.expires_at = Time.now + 1.hour
    @feed.write_attribute(:contents, @contents)
    
    assert_equal @contents, @feed.contents
  end
  
  test "TTL of cached contents should be extended if there is an error fetching the remote contents" do
    [StandardError, Timeout::Error].each do |exception|
      @feed.expires_at = Time.now - 1.hour
      @feed.stubs(:remote_contents).raises(exception)
      @feed.write_attribute(:contents, @contents)
      
      assert_equal @contents, @feed.contents
      assert_equal Time.now.utc + Feed::TTL_ON_ERROR, @feed.expires_at
    end
  end
  
  test "parsed_contents should return the contents parsed by SimpleRSS" do
    @feed.stubs(:contents).returns(@contents)
    SimpleRSS.stubs(:parse).with(@contents).returns(parsed_contents = stub)
    
    assert_equal parsed_contents, @feed.parsed_contents
  end
end
