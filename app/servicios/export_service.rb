
require 'csv'

class ExportService
  MODEL_MAP = {
    "user" => User,
    "brand" => Brand,
    "model" => Model,
    "product" => Product,
    "transaction" => Transaction
  }

  def initialize(type)
    @type = type.to_s.downcase
    @klass = MODEL_MAP[@type]
    raise "Tipo desconocido: #{@type}" unless @klass
  end

  def call

    CSV.generate(
  headers: true, 
  col_sep: ';',          
  row_sep: "\r\n",
  quote_char: '"',
  force_quotes: false
) do |csv|
      csv << headers
      all_records.find_each do |record|
        csv << row_for(record)
      end
    end
  end

  private

  def headers
    case @type
    when "user"
      ["name", "lastname"]
    when "brand"
      ["name"]
    when "model"
      ["name"]
    when "product"
      ["brand", "model", "entry_date", "ownerid"]
    when "transaction"
      ["ownerid", "productid", "date"]
    end
  end

  def all_records
    @klass.all
  end

  def row_for(record)
    case @type
    when "user"
      [
        sanitize_field(record.name),
        sanitize_field(record.lastname)
      ]
    when "brand"
      [sanitize_field(record.name)]
    when "model"
      [sanitize_field(record.name)]
    when "product"
      [
        sanitize_field(record.brand),
        sanitize_field(record.model),
        record.entry_date&.strftime("%Y-%m-%d") || "",
        record.ownerid.to_s
      ]
    when "transaction"
      [
        record.ownerid.to_s,
        record.productid.to_s,
        record.date&.strftime("%Y-%m-%d") || ""
      ]
    end
  end


  def sanitize_field(field)
    return "" if field.nil?
    

    sanitized = field.to_s.strip
    

    sanitized.gsub(/[\r\n\t]/, ' ')
  end
end