class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :set_default_response_format

  private

  def set_default_response_format
    request.format = :json
  end

  def render_success(data = nil, message = nil, status = :ok)
    response = {}
    response[:success] = true
    response[:message] = message if message
    response[:data] = data if data
    render json: response, status: status
  end

  def render_error(message, status = :unprocessable_entity, errors = nil)
    response = {
      success: false,
      message: message
    }
    response[:errors] = errors if errors
    render json: response, status: status
  end

  def paginate_collection(collection, page = 1, per_page = 20)
    page = [page.to_i, 1].max
    per_page = [[per_page.to_i, 1].max, 100].min
    
    offset = (page - 1) * per_page
    paginated = collection.offset(offset).limit(per_page)
    total = collection.count
    
    {
      data: paginated,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: (total.to_f / per_page).ceil,
        total_count: total
      }
    }
  end
end