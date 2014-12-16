require 'aldous/result/failure'
require 'aldous/service/validating'

module Aldous
  module Service
    module ErrorFree
      include Validating

      def self.included(base)
        # we prepend a module into the base class so that we can use super
        # inside the methods in that module to delegate to methods with
        # the same name on the class e.g. the perform method in the
        # PrependedMethods module below calls super which will delegate to
        # the perform method of the class where this module
        # is included
        base.class_eval do
          prepend PrependedMethods
        end
      end

      def default_result_options
        {}
      end

      module PrependedMethods
        def perform
          if defined?(super)
            begin
              unless validator.valid?
                result = validation_failure_result
                return result.class.new(default_result_options.merge(result._options))
              end

              result = super
              result.class.new(default_result_options.merge(result._options))
            rescue => e
              ::Aldous.config.error_reporter.report(e)
              ::Aldous::Result::Failure.new(default_result_options)
            end
          else
            raise "#{self.class.name} must implement the '#{__method__}' method"
          end
        end
      end
    end
  end
end

