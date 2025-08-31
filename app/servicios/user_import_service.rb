class UserImportService
  def initialize(file)
    @file = file
  end

  def call
    success_count = 0
    skipped_count = 0
    errors = []

    begin
      spreadsheet = open_spreadsheet(@file)
      
      # Obtener headers y limpiarlos
      header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }
      
      # Verificar headers de forma más flexible
      expected_header = ["name", "lastname"]
      unless expected_header.all? { |col| header.include?(col) }
        return {
          success_count: 0,
          skipped_count: 0,
          errors: ["El archivo debe contener las columnas 'name' y 'lastname'. Headers encontrados: #{header.join(', ')}"]
        }
      end

      # Obtener índices de las columnas
      name_index = header.index("name")
      lastname_index = header.index("lastname")

      # Procesar cada fila
      (2..spreadsheet.last_row).each do |i|
        begin
          row_array = spreadsheet.row(i).to_a
          next if row_array.all? { |cell| cell.blank? || cell.to_s.strip.blank? }

          # Extraer valores usando índices
          name = row_array[name_index]&.to_s&.strip
          lastname = row_array[lastname_index]&.to_s&.strip

          if name.blank? || lastname.blank?
            errors << "Fila #{i}: Name y lastname son requeridos"
            next
          end

          user = User.find_by(name: name, lastname: lastname)
          
          if user
            skipped_count += 1
          else
            User.create!(name: name, lastname: lastname)
            success_count += 1
          end

        rescue => e
          errors << "Fila #{i}: Error al procesar - #{e.message}"
        end
      end

    rescue => e
      errors << "Error al procesar archivo: #{e.message}"
    end

    {
      success_count: success_count,
      skipped_count: skipped_count,
      errors: errors
    }
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
