class ModelsController < ApplicationController

  def import
    if params[:file].present?
      ModelImportService.new(params[:file]).call
      redirect_to models_path, notice: "Modelos importados correctamente."
    else
      redirect_to models_path, alert: "Por favor sube un archivo."
    end
  rescue => e
    redirect_to models_path, alert: "Error al importar: #{e.message}"
  end
end
