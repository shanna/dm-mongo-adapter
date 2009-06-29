module DataMapper
  module Mongo
    module Types
      class EmbeddedResource < DataMapper::Type
        primitive Object
        default lambda{|r, p| p.type.model.new}

        def self.inherited(target)
          target.instance_variable_set("@primitive", self.primitive)
          target.instance_variable_set("@default", self.default)
        end

        def self.model
          @model
        end

        def self.model=(model)
          @model = model
        end

        def self.new(model)
          klass       = Class.new(self)
          klass.model = model
          klass
        end

        def self.load(value, property)
          value
        end

        def self.dump(value, property)
          value
        end
      end # EmbeddedResource
    end # Types
  end # Mongo
end # DataMapper
