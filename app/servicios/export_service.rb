# app/services/export_service.rb
require 'caxlsx'  # importa caxlsx, pero el módulo sigue siendo Axlsx

class ExportService
  MODEL_MAP = {
    "user" => User,
    "brand" => Brand,
    "model" => Model,
    "product" => Product
  }

  def initialize(type)
    @type = type.to_s.downcase
    @klass = MODEL_MAP[@type]
    raise "Tipo desconocido" unless @klass
  end

  # Devuelve un archivo en memoria
  def call
    package = Axlsx::Package.new  # <- sigue siendo Axlsx::Package
    workbook = package.workbook

    workbook.add_worksheet(name: @type.pluralize.capitalize) do |sheet|
      # Agregar encabezados
      sheet.add_row headers

      # Agregar datos
      all_records.each do |record|
        sheet.add_row row_for(record)
      end
    end

    package
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
    end
  end

  def all_records
    @klass.all
  end

  def row_for(record)
    case @type
    when "user"
      [record.name, record.lastname]
    when "brand"
      [record.name]
    when "model"
      [record.name]
    when "product"
      [record.brand, record.model, record.entry_date&.strftime("%Y-%m-%d"), record.ownerid]
    end
  end
end
