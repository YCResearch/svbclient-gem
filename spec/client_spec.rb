# Encoding: utf-8
require 'spec_helper'
require 'svbclient'
require 'json'

api_key = 'test_LWtcGxvYZoOyxGaxJ4sv5yfHhvZKZMZx'
hmac = ''

describe 'simple requests' do
  it 'should do a GET request' do
    client = SVBClient.new(api_key, hmac)
    j = JSON.parse(client.get("/v1").body)
    expect(j["api_version"]).to eq("1")
    expect(j["fault"]).to eq(nil)
  end

  it 'should do a GET request with no hmac' do
    client = SVBClient.new(api_key)
    j = JSON.parse(client.get("/v1").body)
    expect(j["api_version"]).to eq("1")
    expect(j["fault"]).to eq(nil)
  end

  it 'should do a POST request' do
    client = SVBClient.new(api_key, hmac)
    j = JSON.parse(client.post("/v1", { "a": "b" }).body)
    expect(j["api_version"]).to eq("1")
    expect(j["fault"]).to eq(nil)
  end

  it 'should upload a file' do
    client = SVBClient.new(api_key, hmac)
    client.upload("/v1/files", File.new("./spec/y18.png", "rb"), 'image/png')
  end

  it 'should do a bad request' do
    expect {
      client = SVBClient.new('fail', 'fail')
      client.get("/v1")
    }.to raise_error
  end
end

describe 'onboarding helper' do
  before do
    @client = SVBClient.new(api_key, hmac)
    @onboarding = SVBClient::Onboarding.new(@client)
  end

  it 'creates an address' do
    address = @onboarding.address(street_line1: '221B Baker St', city: 'London', country: 'GB')
    expect(address.data["street_line1"]).to eq("221B Baker St")

    address.update({ street_line1: "222 Baker St" })
    expect(address.data["street_line1"]).to eq("222 Baker St")
  end

  it 'fails to create an address without a city or country' do
    expect {
      address = @onboarding.address(street_line1: '221B Baker St')
    }.to raise_error
  end
end

describe 'Accounts features' do
  before do
    @client = SVBClient.new(api_key, hmac)
  end

  it 'lists all accounts' do
    list = SVBClient::Account.all(@client)
    expect(list.length).to eq(3)
  end

  it 'gets one account details and its transactions' do
    acc = SVBClient::Account.new(@client, '1002')
    record = acc.data
    expect(record["account_number"]).to eq("3457071804647")

    transactions = acc.transactions["transactions"]
    expect(transactions.length).to eq(1000)
  end
end

describe 'ACH features' do
  before do
    @client = SVBClient.new(api_key, hmac)
    @handler = SVBClient::ACHHandler.new(@client)
  end

  it 'creates an ACH' do
    @handler.create({})
  end

  it 'lists all ACHs' do
    all = @handler.all
    expect(all.length).to eq(1)
  end

  it 'gets a specific ACH and status' do
    mine = @handler.get(3728)
    expect(mine.data['status']).to eq('canceled')
  end

  it 'lists canceled ACHs' do
    cancels = @handler.find({ status: 'canceled' })
    expect(cancels.length).to eq(1)
  end

  it 'lists pending ACHs' do
    pendings = @handler.find({ status: 'pending' })
    expect(pendings.length).to eq(0)
  end
end

describe 'Book Transfer features' do
  before do
    @client = SVBClient.new(api_key, hmac)
    @handler = SVBClient::BookTransferHandler.new(@client)
  end

  it 'lists all book transfers' do
    all = @handler.all
    expect(all.length).to eq(12)
  end

  it 'gets a specific record' do
    mine = @handler.get(1011)
    expect(mine.data['status']).to eq('pending')
  end
end

describe 'Wire Transfer features' do
  before do
    @client = SVBClient.new(api_key, hmac)
    @handler = SVBClient::WireHandler.new(@client)
  end

  it 'lists all wire transfers' do
    all = @handler.all
    expect(all.length).to eq(0)
  end
end
