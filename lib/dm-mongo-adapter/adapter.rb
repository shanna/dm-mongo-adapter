module DataMapper
  module Mongo
    class Adapter < DataMapper::Adapters::AbstractAdapter
      def create(resources)
        resources.map do |resource|
          with_connection(resource.model) do |connection|
            connection.insert(resource.attributes(:field).to_mash.symbolize_keys)
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
            connection.modify(key(resource), resource.attributes(:field).merge(attributes_as_fields(attributes)))
          end.size
        end
      end

      def delete(collection)
        with_connection(collection.query.model) do |connection|
          collection.each do |resource|
            connection.remove(key(resource))
          end.size
        end
      end

      private
        def key(resource)
          resource.model.key(name).map(&:field).zip(resource.key).to_mash.symbolize_keys
        end

        def attributes_as_fields(attributes)
          super.to_mash.symbolize_keys
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

  Adapters::MongoAdapter = DataMapper::Mongo::Adapter
  Adapters.const_added(:MongoAdapter)
end # DataMapper

