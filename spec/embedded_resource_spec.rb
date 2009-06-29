require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Mongo::EmbeddedResource do
  before :all do
    # DataMapper::Logger.new(STDOUT, :debug)
    @adapter = DataMapper.setup(:default,
      :adapter  => 'mongo',
      :hostname => 'localhost',
      :database => 'dm-mongo-test'
    )

    db = XGen::Mongo::Driver::Mongo.new.db('dm-mongo-test')
    db.drop_collection('users')

    module ::Stuff
      class Address
        include DataMapper::Mongo::EmbeddedResource
        property :number, Integer
        property :street, String
      end # Address

      class Borrowed
        include DataMapper::Mongo::EmbeddedResource
        property :thing, String
        property :when,  DateTime
      end

      class User
        include DataMapper::Resource
        property :id,       DataMapper::Mongo::Types::ObjectID, :field => '_id', :key => true
        property :address,  DataMapper::Mongo::Types::EmbeddedResource.new(Stuff::Address)
        property :borrowed, DataMapper::Mongo::Types::EmbeddedResources.new(Stuff::Borrowed)
      end # User
    end

    @user_model     = ::Stuff::User
    @address_model  = ::Stuff::Address
    @borrowed_model = ::Stuff::Borrowed
  end

  # TODO: Yeah not a real spec. Just me playing with stuff as I build it.

  it 'should create new embedded resource instance' do
    @user_model.new.address.should be_kind_of(@address_model)
  end

  it { @user_model.new.address.should respond_to(:number) }

  it 'should let me add borrowed stuff' do
    user = @user_model.new
    user.borrowed << @borrowed_model.new(:thing => 'banana')
    user.borrowed << @borrowed_model.new(:thing => 'portal gun')
    user.borrowed.size.should == 2
  end

  it 'should let me save resource' do
    user = @user_model.new
    user.address.number = 10
    user.address.street = 'blah'
    $stderr.puts user.attributes(:field).inspect
    # user.save
  end

  it 'should not have class methods all, first, save etc.'
end
