class TransactionImportService
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
      raw_headers = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }
      
      # Headers esperados para transacciones
      expected_headers = ["ownerid", "productid", "date"]
      
      # Verificar que existan todas las columnas necesarias
      missing_headers = expected_headers.reject { |header| raw_headers.include?(header) }
      unless missing_headers.empty?
        return {
          success_count: 0,
          skipped_count: 0,
          errors: ["Faltan las siguientes columnas: #{missing_headers.join(', ')}. Headers encontrados: #{raw_headers.join(', ')}"]
        }
      end

      # Mapear índices de columnas
      header_map = expected_headers.each_with_object({}) do |col, map|
        map[col] = raw_headers.index(col)
      end

      # Procesar cada fila
      (2..spreadsheet.last_row).each do |i|
        begin
          row = spreadsheet.row(i).to_a
          next if row.all? { |cell| cell.blank? || cell.to_s.strip.blank? }

          # Extraer valores usando índices
          owner_id = row[header_map["ownerid"]].to_i rescue nil
          product_id = row[header_map["productid"]].to_i rescue nil
          date_raw = row[header_map["date"]]

          # Validaciones básicas
          if owner_id.blank? || owner_id == 0
            errors << "Fila #{i}: ownerid es requerido y debe ser un número válido"
            next
          end

          if product_id.blank? || product_id == 0
            errors << "Fila #{i}: productid es requerido y debe ser un número válido"
            next
          end

          # Verificar que el usuario existe
          owner = User.find_by(id: owner_id)
          unless owner
            errors << "Fila #{i}: Usuario con ID #{owner_id} no existe"
            next
          end

          # Verificar que el producto existe
          product = Product.find_by(id: product_id)
          unless product
            errors << "Fila #{i}: Producto con ID #{product_id} no existe"
            next
          end

          # Convertir fecha
          transaction_date = begin
            if date_raw.is_a?(Date) || date_raw.is_a?(Time)
              date_raw.to_date
            elsif date_raw.present?
              Date.parse(date_raw.to_s)
            else
              Date.current  # Fecha actual si no se proporciona
            end
          rescue => date_error
            errors << "Fila #{i}: Fecha inválida '#{date_raw}' - #{date_error.message}"
            next
          end

          # Verificar si ya existe una transacción similar
          existing_transaction = Transaction.find_by(
            ownerid: owner_id,
            productid: product_id,
            date: transaction_date
          )

          if existing_transaction
            skipped_count += 1
            next
          end

          # Crear la transacción
          transaction = Transaction.new(
            ownerid: owner_id,
            productid: product_id,
            date: transaction_date
          )

          if transaction.save
            success_count += 1
          else
            errors << "Fila #{i}: Error al crear transacción - #{transaction.errors.full_messages.join(', ')}"
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