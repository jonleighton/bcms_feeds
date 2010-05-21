class ModifyFeedsTableToUseMediumtext < ActiveRecord::Migration
  def self.up
    if Feed.connection.adapter_name == 'MySQL'
      #The postgres text column suffices, and this syntax and column type don't work in pg.
      execute "ALTER TABLE feeds MODIFY COLUMN contents MEDIUMTEXT"
    end
  end

  def self.down
    if Feed.connection.adapter_name == 'MySQL'
      #The postgres text column suffices, and this syntax and column type don't work in pg.
      execute "ALTER TABLE feeds MODIFY COLUMN contents TEXT"
    end
  end
end
