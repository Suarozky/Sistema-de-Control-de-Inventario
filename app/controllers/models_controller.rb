class ModelsController < ApplicationController
  def index
    @models = Model.all
  end

  def import
    if params[:file].present?
      Model.import(params[:file])
      redirect_to models_path, notice: "Modelos importados correctamente."
    else
      redirect_to models_path, alert: "Por favor sube un archivo."
    end
  end
end
