require File.dirname(__FILE__) + "/../test_helper"

class FeedTest < ActiveSupport::TestCase
  def setup
    @feed = Feed.create!(:url => "http://example.com/blog.rss")
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
    should_get_remote_contents_and_parse
  end
  
  test "contents with an expiry in the past return the remote contents and save it" do
    @feed.expires_at = Time.now - 1.hour
    should_get_remote_contents_and_parse
  end
  
  def should_get_remote_contents_and_parse
    @feed.stubs(:remote_contents).returns(@contents)
    SimpleRSS.expects(:parse).with(@contents)
    
    assert_equal @contents, @feed.contents
    @feed.reload
    assert_equal @contents, @feed.read_attribute(:contents)
    
    # I think the to_i is necessary because of a lack of precision provided by sqlite3. I think.
    # Anyway, without it the comparison fails.
    assert_equal (Time.now.utc + Feed::TTL).to_i, @feed.expires_at.to_i
  end
  
  test "contents with the expiry in the future should return the cached contents" do
    @feed.expires_at = Time.now + 1.hour
    @feed.write_attribute(:contents, @contents)
    
    assert_equal @contents, @feed.contents
  end
  
  test "TTL of cached contents should be extended if there is an error fetching the remote contents, or parsing the feed" do
    [StandardError, Timeout::Error, SimpleRSSError].each do |exception|
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
  
  test "Contents can be larger than 64Kb of text in a feed" do
    feed = Feed.new(:url => 'http://www.foo.com', :contents => '<feed>' + 'w' * 300000 + '</feed>', :expires_at => Time.now + 15.minutes)
    feed.save
    
    assert_equal 'http://www.foo.com', feed.url
    assert_equal '<feed>' + 'w' * 300000 + '</feed>', feed.contents
  end
end
