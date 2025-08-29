# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def new
  @products = Product.all
  @users = User.all
  @brands = Brand.all
  @models = Model.all
end
# app/controllers/home_controller.rb
def export
  type = params[:type]
  package = ExportService.new(type).call

  # Genera un nombre de archivo con timestamp
  filename = "#{type.pluralize}_#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"

  # Forzar descarga
  send_data package.to_stream.read,
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            filename: filename
end


end
