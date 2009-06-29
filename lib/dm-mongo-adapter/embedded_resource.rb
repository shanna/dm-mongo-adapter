module DataMapper
  module Mongo
    module Model
      def property(name, type, options = {})
        # TODO: Are these going to be actual properties?
        # I can't create them or use the property method in DM::Model::Property without an actual DataMapper::Model.
      end
    end

    #--
    # TODO:
    # * A DataMapper::Resource except without a collection/table of it's own?
    # * Just method creation like DataMapper::Model::Property?
    module EmbeddedResource
      include Extlib::Assertions

      def self.included(model)
        model.extend DataMapper::Model::Property
        model.extend Model
      end
    end
  end # Mongo
end # DataMapper
