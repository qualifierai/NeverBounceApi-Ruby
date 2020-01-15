require "never_bounce/api/error"

module NeverBounce
  module API
    module Feature
      # Provide attribute validation method(s) to the owner class.
      # @see InstanceMethods#initialize
      module RequireAttr
        # @param owner [Class]
        # @return [nil]
        def self.load(owner)
          return if owner < InstanceMethods
          owner.send(:include, InstanceMethods)
        end

        module InstanceMethods
          private

          # Require attribute to be set. Return attribute value.
          # @return [mixed]
          def require_attr(name)
            send(name).tap do |_|
              if _.respond_to?(:body)
                raise AttributeError, "Attribute must be set: #{name}" if _.body.nil? || _.body.empty?
              else
                raise AttributeError, "Attribute must be set: #{name}" if _.nil?
              end
            end
          end
        end
      end
    end; end; end
