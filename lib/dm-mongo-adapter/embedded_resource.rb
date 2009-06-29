module DataMapper
  module Mongo
    #--
    # TODO:
    # * A DataMapper::Resource except without a collection/table of it's own?
    # * Just method creation like DataMapper::Model::Property?
    module EmbeddedResource
      include Extlib::Assertions

      def self.included(model)
        model.extend DataMapper::Model
        model.property :_id, Types::ObjectID, :key => true
      end
    end
  end # Mongo
end # DataMapper
