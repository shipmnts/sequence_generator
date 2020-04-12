module SequenceGenerator
  class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found
    rescue_from ActionController::ParameterMissing, with: :parameter_missing

    protected

    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def resource_not_found(exception)
      api_error(status: :not_found, message: "#{exception.model} for given id Not found")
    end

    def parameter_missing(exception)
      api_error(status: :bad_request, message: exception.message)
    end

    def invalid_resource!(message)
      api_error(status: :bad_request, message: message)
    end

    def valid_params?(param_hash, keys)
      keys.each do |key|
        unless param_hash[key].present?
          invalid_resource!("#{key} is missing")
          return false
        end
      end
      true
    end

    def api_error(status: 500, message: "", errors: [] )
      if errors.respond_to? :full_messages
        puts colorize(errors.full_messages, 36)
      else
        puts colorize(message, 35)
      end
      head status: status and return if message.empty?
      render json: jsonapi_format(status, message, errors).to_json, status: status
    end

    private

    def jsonapi_format(status, message, errors)
      http_status_code = Rack::Utils.status_code(status)
      title = Rack::Utils::HTTP_STATUS_CODES[http_status_code]
      error_hash = {status: http_status_code, title: title, message: message }
      return error_hash unless errors.present?
      errors_array = []
      if errors.is_a?(Array)
        errors.each do |err|
          err.messages.each do |attribute, error|
            messages = []
            error.each do |e|
              messages <<  e
            end
            errors_array << {attribute: attribute, messages: messages}
          end
        end
      else
        errors.messages.each do |attribute, error|
          messages = []
          error.each do |e|
            messages <<  e
          end
          errors_array << {attribute: attribute, messages: messages}
        end
      end
      error_hash.merge!(details: errors_array)
    end

  end
end
