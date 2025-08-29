# app/services/user_import_service.rb
class UserImportService
  def initialize(file)
    @file = file
  end

  def call
    spreadsheet = Roo::Spreadsheet.open(@file.path)
    header = spreadsheet.row(1).map(&:to_s)  # Asegurarse que sean strings

    expected_header = ["name", "lastname"]
    unless header == expected_header
      raise "El archivo de Users debe tener las columnas en este orden: #{expected_header.join(', ')}"
    end

    (2..spreadsheet.last_row).each do |i|
      row_array = spreadsheet.row(i).to_a      # Forzar a array
      next if row_array.all?(&:blank?)          # Ignorar filas vacías

      row_hash = Hash[[header, row_array].transpose]

      User.find_or_create_by(
        name: row_hash["name"].to_s.strip,
        lastname: row_hash["lastname"].to_s.strip
      )
    end
  end
end
