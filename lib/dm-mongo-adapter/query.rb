module DataMapper
  module Mongo
    class Query
      include Extlib::Assertions
      include DataMapper::Query::Conditions

      def initialize(connection, query)
        assert_kind_of 'connection', connection, XGen::Mongo::Driver::Collection
        assert_kind_of 'query', query, DataMapper::Query
        @connection, @query, @statements = connection, query, {}
      end

      def read
        options         = {}
        options[:limit] = @query.limit if @query.limit
        options[:sort]  = sort_statement(@query.order) unless @query.order.empty?

        condition_statement(@query.conditions)
        DataMapper.logger.info("Mongo ~ #{@statements.inspect}")
        @connection.find(@statements, options).to_a
      end

      private
        def condition_statement(conditions, affirmative = true)
          case conditions
            when AbstractOperation  then operation_statement(conditions, affirmative)
            when AbstractComparison then comparison_statement(conditions, affirmative)
          end
        end

        def operation_statement(operation, affirmative = true)
          case operation
            when NotOperation then condition_statement(operation.first, !affirmative)
            when AndOperation then operation.each{|op| condition_statement(op, affirmative)}
            when OrOperation  then raise NotImplementedError
          end
        end

        #--
        # TODO: Rather than raise an error do what we can in a $where operation or in memory.
        def comparison_statement(comparison, affirmative = true)
          field = comparison.subject.field
          value = comparison.value

          operator = if affirmative
            case comparison
              when value.kind_of?(Range) && value.exclude_end? then {'$gte' => value.first, '$lt' => value.last}
              when EqualToComparison                           then value
              when GreaterThanComparison                       then {'$gt'  => value}
              when LessThanComparison                          then {'$lt'  => value}
              when GreaterThanOrEqualToComparison              then {'$gte' => value}
              when LessThanOrEqualToComparison                 then {'$lte' => value}
              when InclusionComparison                         then {'$in'  => value}
              when RegexpComparison                            then value
              when LikeComparison                              then like_comparison_regexp(value)
              else raise NotImplementedError
            end
          else
            case comparison
              when value.kind_of?(Range) && value.exclude_end? then {'$lte' => value.first, '$gt' => value.last}
              when EqualToComparison                           then {'$ne'  => value}
              when InclusionComparison                         then {'$nin' => value}
              else raise NotImplementedError
            end
          end

          @statements.update(field.to_sym => operator)
        end

        def sort_statement(conditions)
          conditions.inject(OrderedHash.new) do |hash, condition|
            hash[condition.target.field] = condition.operator == :asc ? 1 : -1
            hash
          end
        end

        def like_comparison_regexp(value)
          # TODO: %% isn't supported. It isn't in LikeComparison's matches? fyi.
          Regexp.new(value.to_s.gsub(/^([^%])/, '^\\1').gsub(/([^%])$/, '\\1$').gsub(/%/, '.*').gsub('_', '.'))
        end
    end # Query
  end # Mongo
end # DataMapper

