module DataMapper
  module Adapters
    module Mongo
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
  end # Adapters
end # DataMapper
