module DataMapper
  module Adapters
    module Mongo
      class Adapter < AbstractAdapter
        def create(resources)
          resources.map do |resource|
            model          = resource.model
            identity_field = model.identity_field

            with_connection(model) do |connection|
              initialize_identity_field(resource, XGen::Mongo::Driver::ObjectID.new) if identity_field
              connection.insert(resource.attributes(:field).merge(:_id => key(resource)))
            end
          end.size
        end

        def read(query)
          with_connection(query.model) do |connection|
            Query.new(connection, query).read
          end
        end

        def update(attributes, collection)
          with_connection(collection.query.model) do |connection|
            collection.each do |resource|
              connection.modify({:_id => key(resource)}, attributes_as_fields(attributes))
            end.size
          end
        end

        def delete(collection)
          with_connection(collection.query.model) do |connection|
            collection.each do |resource|
              connection.remove({:_id => key(resource)})
            end.size
          end
        end

        private
          def key(resource)
            key = resource.key
            key.size > 1 ? key.join(':') : key.first
          end

          #--
          # TODO: Thread.current[:dm_mongo_connection_stack] stuff in case you multi-thread this mofo?
          def with_connection(model)
            begin
              driver     = XGen::Mongo::Driver::Mongo.new(*@options.values_at(:host, :port))
              connection = driver.db(@options.fetch(:path, @options[:database])) # TODO: :pk => @options[:pk]
              yield connection.collection(model.storage_name(name))
            rescue Exception => exception
              DataMapper.logger.error(exception.to_s)
              raise exception
            ensure
              connection.close if connection
            end
          end
      end # Adapter
    end # Mongo

    MongoAdapter = Mongo::Adapter
    const_added(:MongoAdapter)
  end # Adapters
end # DataMapper

