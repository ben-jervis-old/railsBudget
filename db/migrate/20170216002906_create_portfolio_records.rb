class CreatePortfolioRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :portfolio_records do |t|
      t.string :code
      t.string :name
      t.integer :quantity
      t.decimal :price
      t.decimal :value
      t.date :date

      t.timestamps
    end
  end
end
