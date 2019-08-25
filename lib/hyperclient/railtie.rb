module Hyperclient
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'hyperclient.client.attach_log_subscriber' do
      ActiveSupport.on_load(:active_job) do
        require 'hyperclient/global_id'

        ::Hyperclient::GlobalId.setup!
      end
    end
  end
end
