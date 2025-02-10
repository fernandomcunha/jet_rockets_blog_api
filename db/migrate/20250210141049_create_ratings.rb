class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_check_constraint :ratings, "value BETWEEN 1 AND 5", name: "value_range_check"
    add_index :ratings, [:user_id, :post_id], unique: true, name: 'index_ratings_on_user_id_and_post_id'
  end
end
