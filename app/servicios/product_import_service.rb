class ProductImportService
  def initialize(file)
    @file = file
  end

  def call
    spreadsheet = open_spreadsheet(@file)
    raw_headers = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }

    expected_headers = ["brand", "model", "entry_date", "ownerid"]

    # Mapear índices de columnas
    header_map = expected_headers.each_with_object({}) do |col, map|
      idx = raw_headers.index(col)
      raise "Falta columna esperada: #{col}" unless idx
      map[col] = idx
    end

    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i).to_a
      next if row.all?(&:blank?)

      brand_name = row[header_map["brand"]]&.to_s&.strip
      model_name = row[header_map["model"]]&.to_s&.strip
      entry_date_raw = row[header_map["entry_date"]]
      owner_id = row[header_map["ownerid"]].to_i rescue nil
      owner = User.find_by(id: owner_id)

      next unless brand_name.present? && model_name.present?

      brand = Brand.find_or_create_by(name: brand_name)
      model = Model.find_or_create_by(name: model_name)

      # Convertir entry_date a fecha si es posible
      entry_date = begin
        if entry_date_raw.is_a?(Date) || entry_date_raw.is_a?(Time)
          entry_date_raw.to_date
        else
          Date.parse(entry_date_raw.to_s)
        end
      rescue
        nil
      end

      product = Product.new(
        brand: brand.name,
        model: model.name,
        entry_date: entry_date,
        ownerid: owner&.id
      )

      unless product.save
        Rails.logger.warn "No se pudo crear el producto en la fila #{i}: #{product.errors.full_messages.join(', ')}"
      end
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
