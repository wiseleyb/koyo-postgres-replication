# frozen_string_literal: true

class CreateKoyoPostgresReplicationUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false, index: true
      t.timestamps
    end
  end
end
