class AddLastNonceToApiKey < ActiveRecord::Migration
  def change
    add_column :api_keys, :last_nonce, :integer
  end
end
