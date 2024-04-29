module API
  class Logger < Grape::Middleware::Base
    def before
      log_api(:info,
              'api-request',
              { method: env['REQUEST_METHOD'],
                path: env['PATH_INFO'],
                data: env['rack.request.form_hash'] })
    end

    def after
      log_api(:info,
              'api-response',
              { inputs: input_params, status: response_status, response_body: })
      @app_response # this must return @app_response or nil
    end

    private

    def input_params
      JSON.parse(env['api.request.input'].to_s)
    rescue JSON::ParserError => e
      log_api(:error,
              'api-input-params',
              { message: 'Error parsing API input parameters', input_params: env['api.request.input'] },
              e)
    end

    def response_status
      return if @app_response.blank?

      @app_response.first.to_s
    end

    def response_body
      return if @app_response.blank?

      JSON.parse(@app_response[2].first)
    rescue JSON::ParserError => e
      log_api(:error,
              'api-response-body',
              "Error parsing API response body: \n#{@app_response[2].first}",
              e)
    end

    def log_api(level, type, message, error = nil)
      LogStuff.send(
        level.to_sym,
        type:,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
          message
      end
    end
  end
end
