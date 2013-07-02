class AddSessionId < ActiveRecord::Migration
  def up
  	add_column :logs,:session_id,:string
  end

  def down
  	remove_column :logs,:session_id,:string
  end
end
