module DataMapper
  module Mongo
    module Types
      class EmbeddedResource < DataMapper::Type
        primitive Object
        default lambda{|r, p| p.type.resource.new}

        def self.inherited(target)
          target.instance_variable_set("@primitive", self.primitive)
          target.instance_variable_set("@default", self.default)
        end

        def self.resource
          @resource
        end

        def self.resource=(resource)
          @resource = resource
        end

        def self.new(model)
          klass          = Class.new(self)
          klass.resource = model
          klass
        end

        def self.load(value, property)
          if value.nil?
            nil
          elsif value.kind_of?(Hash)
            resource.load(value)
          else
            raise ArgumentError.new('+value+ must be nil or Hash')
          end
        end

        def self.dump(value, property)
          value # .to_mongo
        end
      end # EmbeddedResource
    end # Types
  end # Mongo
end # DataMapper
