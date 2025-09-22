
class ModelImportService
  def initialize(file)
    @file = file
  end

  def call
    spreadsheet = open_spreadsheet(@file)
    header = spreadsheet.row(1).map(&:to_s)

    expected_header = ["name"]
    unless header == expected_header
      raise "El archivo de Models debe tener solo la columna: #{expected_header.join(', ')} en ese orden"
    end

    (2..spreadsheet.last_row).each do |i|
      row_array = spreadsheet.row(i).to_a
      next if row_array.all?(&:blank?)  

      row_hash = Hash[[header, row_array].transpose]
      Model.find_or_create_by(name: row_hash["name"].to_s.strip)
    end
  end

  private

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv"  then Roo::CSV.new(file.path)
    when ".xls"  then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else
      raise "Formato de archivo no soportado: #{file.original_filename}"
    end
  end
end
