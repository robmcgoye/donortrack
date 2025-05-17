class AddStatusInkindFundsTransfer < ActiveRecord::Migration[7.2]
  def change
    add_column :in_kinds, :status, :integer, default: 0, null: false
    add_column :funds_transfers, :status, :integer, default: 0, null: false
  end
end
