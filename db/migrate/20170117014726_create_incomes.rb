class CreateIncomes < ActiveRecord::Migration[5.0]
  def change
    create_table :incomes do |t|
      t.string :title
      t.float :amount
      t.string :frequency

      t.timestamps
    end
  end
end
