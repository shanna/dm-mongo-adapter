require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Mongo::EmbeddedResource do
  before :all do
    module ::Blog
      class Address
        include DataMapper::Mongo::EmbeddedResource
        property :number, Integer
        property :street, String
      end # Address

      class User
        include DataMapper::Resource
        property :id,      DataMapper::Mongo::Types::ObjectID, :field => '_id', :key => true
        property :address, DataMapper::Mongo::Types::EmbeddedResource.new(Blog::Address)
      end # User
    end

    @user_model    = ::Blog::User
    @address_model = ::Blog::Address
  end

  it 'should create new embedded resource instance' do
    @user_model.new.address.should be_kind_of(@address_model)
  end
end
