# frozen_string_literal: true

class CreateCompositeKeyTest < ActiveRecord::Migration[7.0]
  def up
    create_table :interests do |t|
      t.string :name, null: false, index: true

      t.timestamps
    end

    sql = %(
      CREATE TABLE user_interests_non_rails(
        user_id INTEGER,
        interest_id INTEGER,
        created_at timestamp(6) without time zone,
        updated_at timestamp(6) without time zone,
        PRIMARY KEY (user_id, interest_id)
      );
    )
    connection.execute(sql)
  end

  def down
    sql = %(DROP TABLE interests; DROP TABLE user_interests_non_rails;)
    connection.execute(sql)
  end
end
