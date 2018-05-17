require 'rack/proxy'

module RosieProxy
  class Proxy < Rack::Proxy

    HTTP_CODE_NOT_FOUND = 404.freeze
    ROUTING_ERROR_MESSAGE_NOT_FOUND = 'Not Found'.freeze

    alias_method :parent_perform_request, :perform_request
    private :parent_perform_request

    def perform_request(env)
      result_proxy = [HTTP_CODE_NOT_FOUND]
      begin
        result = @app.call(env)
        if result.first.to_i == HTTP_CODE_NOT_FOUND
          result_proxy = handle_proxy_request(env)
        end
      rescue ActionController::RoutingError => error
        if error.message == ROUTING_ERROR_MESSAGE_NOT_FOUND
          result_proxy = handle_proxy_request(env)
          raise error if result_proxy.first.to_i == HTTP_CODE_NOT_FOUND
        else
          raise error
        end
      rescue ActionController::InvalidAuthenticityToken => error
        result_proxy = handle_proxy_request(env)
      end

      result_proxy.first.to_i == HTTP_CODE_NOT_FOUND ?  result : replace_links(result_proxy, env)
    end

    private

    def handle_proxy_request(env)
      result = [HTTP_CODE_NOT_FOUND]
      env['HTTP_X_ROSIE_PROXY'] = 'true'
      env['HTTP_X_ROSIE_PROXY_HOST'] = env['HTTP_HOST']
      env['HTTP_X_ROSIE_PROXY_SCHEME'] = env['rack.url_scheme']

      proxy_configs.each do |proxy_name, proxy_config|
        wrap_instance_variable(proxy_config) do
          wrap_http_headers(env, proxy_config) do
            env['rack.backend'] = backend_uri(proxy_config)
            env['rack.ssl_verify_none'] = proxy_config['rack.ssl_verify_none'] if proxy_config['ssl_verify_none']
            env['http.read_timeout'] = proxy_config['timeout'] if proxy_config['timeout']
            result = parent_perform_request(env)
          end
        end
        break if result.first.to_i != HTTP_CODE_NOT_FOUND
      end
      result
    end

    def proxy_configs
      @proxy_configs ||= Rails.application.config_for('proxy')
    end

    def backend_uri(proxy_config)
      URI.parse(proxy_config['backend'])
    end

    def wrap_ssl_version(proxy_config)
      prev = @ssl_version
      @ssl_version = proxy_config['ssl_version'] if proxy_config['ssl_version']
      yield
      @ssl_version = prev
    end

    def wrap_streaming(proxy_config)
      prev = @streaming
      @streaming = proxy_config['streaming'] unless proxy_config['streaming'].nil?
      yield
      @streaming = prev
    end

    def wrap_instance_variable(proxy_config)
      wrap_ssl_version proxy_config do
        wrap_streaming proxy_config do
          yield
        end
      end
    end

    def wrap_http_headers(env, proxy_config)
      prev_http_host = env['HTTP_HOST']
      env['HTTP_HOST'] = proxy_config['http_host'] if proxy_config['http_host'].present?
      yield
      env['HTTP_HOST'] = prev_http_host
    end

    def replace_links(result, env)
      result[2].map!{|s| s.is_a?(String) ? s.gsub(/(https?:)?\/\/#{Regexp.escape(env['HTTP_HOST'])}/, "//#{env['HTTP_X_ROSIE_PROXY_HOST']}") : s}
      result
    end
  end
end
