require 'dm-core'
require 'mongo'
require 'json'
require 'pp'

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

      class Query
        include Extlib::Assertions
        include DataMapper::Query::Conditions

        def initialize(connection, query)
          assert_kind_of 'connection', connection, XGen::Mongo::Driver::Collection
          assert_kind_of 'query', query, DataMapper::Query
          @connection, @query = connection, query
        end

        def read
          options         = {}
          options[:limit] = @query.limit if @query.limit
          options[:sort]  = sort_statement(@query.order) unless @query.order.empty?
          selector        = condition_statement(@query.conditions)
          @connection.find(selector, options).to_a
        end

        private
          def condition_statement(conditions)
            case conditions
              when AbstractOperation  then operation_statement(conditions)
              when AbstractComparison then comparison_statement(conditions)
            end
          end

          def operation_statement(operation)
            expression = operation.map{|op| condition_statement(op)}.flatten.compact
            return if expression.empty?
            case operation
              when NotOperation then ['!(', expression.join, ')'].join
              when AndOperation then ['(', expression.join(' && '), ')'].join
              when OrOperation  then ['(', expression.join(' || '), ')'].join
            end
          end

          def comparison_statement(comparison)
            value     = comparison.value
            primitive = comparison.subject.primitive

            if value.kind_of?(Range) && value.exclude_end?
              operation = BooleanOperation.new(:and,
                Comparison.new(:gte, comparison.property, value.first),
                Comparison.new(:lt, comparison.property, value.last)
              )
              return operation_statement(operation)
            end

            operator = case comparison
              when EqualToComparison              then '==='
              when GreaterThanComparison          then '>'
              when LessThanComparison             then '<'
              when GreaterThanOrEqualToComparison then '>='
              when LessThanOrEqualToComparison    then '<='
              when InclusionComparison
                return "#{serialize(value)}.indexOf(this.#{comparison.subject.field}) != -1"
              when RegexpComparison
                return "#{value.inspect}.test(this.#{comparison.subject.field})"
              when LikeComparison
                # TODO: This hacks needs to be way better.
                re = Regexp.new(Regexp.quote(value.gsub!(/%/, '')))
                return "#{re.inspect}.test(this.#{comparison.subject.field})"
              else return
            end

            ["this.#{comparison.subject.field}", operator, serialize(value)].join(' ')
          end

          def sort_statement(conditions)
            conditions.map do |condition|
              [condition.target.field, condition.operator == :asc ? 1 : -1]
            end.to_hash
          end

          def serialize(value)
            value.to_json
          end
      end # Query
    end # Mongo

    MongoAdapter = Mongo::Adapter
    const_added(:MongoAdapter)
  end # Adapters
end # DataMapper
