class AddStatusSetAtToInKinds < ActiveRecord::Migration[7.2]
  def change
    add_column :in_kinds, :status_set_at, :datetime
    add_column :funds_transfers, :status_set_at, :datetime
  end
end
