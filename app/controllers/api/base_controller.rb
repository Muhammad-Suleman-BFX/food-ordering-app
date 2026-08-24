module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

    private

    def money(value)
      format("%.2f", value)
    end

    def render_not_found(exception)
      model_name = exception.model&.underscore&.humanize || "Record"
      render json: { error: "#{model_name} not found" }, status: :not_found
    end

    def render_parameter_missing(exception)
      render json: { error: "Missing parameter: #{exception.param}" }, status: :bad_request
    end

    def render_record_invalid(exception)
      render json: {
        error: exception.record.errors.full_messages.to_sentence,
        details: exception.record.errors.to_hash
      }, status: :unprocessable_entity
    end

    def render_validation_error(record)
      render json: {
        error: record.errors.full_messages.to_sentence,
        details: record.errors.to_hash
      }, status: :unprocessable_entity
    end
  end
end
