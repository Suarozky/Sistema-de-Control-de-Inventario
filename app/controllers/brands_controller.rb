class BrandsController < ApplicationController
  def index
    @brands = Brand.all
  end

  def import
    if params[:file].present?
      Brand.import(params[:file])
      redirect_to brands_path, notice: "Marcas importadas correctamente."
    else
      redirect_to brands_path, alert: "Por favor sube un archivo."
    end
  end
end
