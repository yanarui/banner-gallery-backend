class AddCompanyNameToBanners < ActiveRecord::Migration[8.0]
  def change
    add_column :banners, :company_name, :string
  end
end
