# frozen_string_literal: true

require 'delegate'
require 'globalid'

module Hyperclient
  module GlobalId
    class Locator
      def locate(gid)
        Hyperclient
          .lookup_entry_point(gid.params['endpoint'])
          .public_send(gid.params['key'], gid.params.except('app', 'endpoint', 'key'))
      end
    end

    class Serializable < SimpleDelegator
      def id
        _url
      end
    end

    private_constant :Serializable

    def self.app_name
      "#{GlobalID.app}-hyperclient"
    end

    def self.setup!
      ::Hyperclient::Link.include ::GlobalID::Identification
      ::Hyperclient::Link.prepend ::Hyperclient::GlobalId

      ::GlobalID::Locator.use app_name, ::Hyperclient::GlobalId::Locator.new
    end

    def to_global_id(options = {})
      GlobalID.create(Serializable.new(self), default_global_id_options.merge(options))
    end
    alias to_gid to_global_id

    def to_signed_global_id(options = {})
      SignedGlobalID.create(Serializable.new(self), default_global_id_options.merge(options))
    end
    alias to_sgid to_signed_global_id

    private

    def default_global_id_options
      {
        app: ::Hyperclient::GlobalId.app_name,
        endpoint: @entry_point._url,
        key: @key,
        **@uri_variables || {},
      }
    end
  end
end