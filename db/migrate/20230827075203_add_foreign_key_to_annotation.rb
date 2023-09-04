class AddForeignKeyToAnnotation < ActiveRecord::Migration[6.0]
  def change
    add_reference :annotations, :image, foreign_key: true
  end
end
