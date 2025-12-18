class CreateContents < ActiveRecord::Migration[8.0]
  def change
    create_table :contents do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :order
      t.text :body
      t.string :type
      t.json :metadata

      t.timestamps
    end
  end
end
