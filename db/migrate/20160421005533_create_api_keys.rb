class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.references :user, index: true, foreign_key: true
      t.string :public
      t.string :secret

      t.timestamps null: false
    end
  end
end
