class AddFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |f|
      f.string :url
      f.text :contents
      f.datetime :expires_at
    end
  end

  def self.down
    drop_table :feeds
  end
end
