class ModifyFeedsTableToUseMediumtext < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE feeds MODIFY COLUMN contents MEDIUMTEXT"
  end

  def self.down
    execute "ALTER TABLE feeds MODIFY COLUMN contents TEXT"
  end
end
