# app/services/brand_import_service.rb
class BrandImportService
  def initialize(file)
    @file = file
  end

  def call
    spreadsheet = Roo::Spreadsheet.open(@file.path)
    header = spreadsheet.row(1).map(&:to_s)

    expected_header = ["name"]
    unless header == expected_header
      raise "El archivo de Brands debe tener solo la columna: #{expected_header.join(', ')} en ese orden"
    end

    (2..spreadsheet.last_row).each do |i|
      row_array = spreadsheet.row(i).to_a
      next if row_array.all?(&:blank?)  # Ignorar filas vacías

      row_hash = Hash[[header, row_array].transpose]
      Brand.find_or_create_by(name: row_hash["name"].to_s.strip)
    end
  end
end
