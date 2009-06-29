module DataMapper
  module Mongo
    module Types
      class EmbeddedResources < EmbeddedResource
        primitive Object

        # TODO: I think I want some sort of lazy loaded collection here.
        default lambda{|r, p| Array.new}

        def self.inherited(target)
          target.instance_variable_set("@primitive", self.primitive)
          target.instance_variable_set("@default", self.default)
        end

        def self.load(value, property)
          if value.nil?
            nil
          elsif value.is_a?(Array)
            # TODO: I think this should be some sort of lazy loaded collection here.
            # TODO: Each resource should be loaded as an instance of self.resource.
            value.map{|record| self.resource.load(record)}
          else
            raise ArgumentError.new('+value+ must be nil or Array')
          end
        end
      end # EmbeddedResources
    end # Types
  end # Mongo
end # DataMapper
