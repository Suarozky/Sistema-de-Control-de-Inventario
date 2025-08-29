class Brand < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1) # primera fila como encabezado

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      Brand.find_or_create_by(name: row["name"])
    end
  end
end
