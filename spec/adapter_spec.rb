require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), 'shared', 'adapter_shared_spec')

describe DataMapper::Adapters::MongoAdapter do
  before :all do
    # DataMapper::Logger.new(STDOUT, :debug)
    @adapter = DataMapper.setup(:default,
      :adapter  => 'mongo',
      :hostname => 'localhost',
      :database => 'dm-mongo-test'
    )

    db = XGen::Mongo::Driver::Mongo.new.db('dm-mongo-test')
    db.drop_collection('heffalumps')
  end

  it_should_behave_like 'An Adapter'
end
