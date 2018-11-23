class ChangeTasksNameNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :tasks, :name, false
    # change_column_null テーブル名 カラム名 NULLを許容するかどうか
  end
end
