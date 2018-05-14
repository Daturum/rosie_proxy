require 'rosie_proxy/proxy'

Rails.application.config.middleware.use RosieProxy::Proxy
