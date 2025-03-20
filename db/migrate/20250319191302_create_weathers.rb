class CreateWeathers < ActiveRecord::Migration[8.0]
  def change
    create_table :weathers do |t|
      t.string :zip_code
      t.decimal :temperature
      t.decimal :high_temp
      t.decimal :low_temp
      t.string :description
      t.datetime :cached_at

      t.timestamps
    end
  end
end
