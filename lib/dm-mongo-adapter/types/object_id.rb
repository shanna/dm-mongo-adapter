module DataMapper
  module Mongo
    module Types
      class ObjectID < DataMapper::Type
        primitive ::Object
        default lambda{|r, p| XGen::Mongo::Driver::ObjectID.new}

        def self.load(value, property)
          typecast(value, property)
        end

        def self.dump(value, property)
          typecast(value, property)
        end

        def self.typecast(value, property)
          if value.nil?
            nil
          elsif value.is_a?(String)
            XGen::Mongo::Driver::ObjectID.from_string(value)
          elsif value.is_a?(XGen::Mongo::Driver::ObjectID)
            value
          else
            raise ArgumentError.new('+value+ must be nil, String or ObjectID')
          end
        end
      end # ObjectID
    end # Types
  end # Mongo
end # DataMapper
