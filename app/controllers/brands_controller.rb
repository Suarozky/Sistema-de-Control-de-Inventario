class BrandsController < ApplicationController

  def index
  @brands = Brand.all
  respond_to do |format|
    format.html { render :index }
    format.json { render json: @brands }
  end
end

  def import
    if params[:file].present?
      BrandImportService.new(params[:file]).call
      redirect_to brands_path, notice: "Marcas importadas correctamente."
    else
      redirect_to brands_path, alert: "Por favor sube un archivo."
    end
  rescue => e
    redirect_to brands_path, alert: "Error al importar: #{e.message}"
  end
end