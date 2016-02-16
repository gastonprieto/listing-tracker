_ = require('lodash')
nock = require('nock')
should = require("chai").should()
SellerListingsUpdater = require('./run')

describe 'SellerListingsUpdater', ->

  @.timeout(5000);

  serverML = nock('https://api.mercadolibre.com')
  serverLocalhost = nock('http://localhost:9000')

  items = _.times 270, (i) ->
    id: 'MLM' + i,
    seller_id: 154901871,
    title: 'title' + i,
    sold_quantity: i


  beforeEach = ->
    nock.disableNetConnect()

  afterEach = ->
    nock.cleanAll();
    nock.enableNetConnect()

  mockML = (offset, total) ->
    serverML
      .get '/sites/MLM/search'
      .query
        limit: 50,
        offset: offset,
        seller_id: 154901871
      .reply 200,
        paging:
          total: total,
          offset: offset,
          limit: 50
        results:
          items[offset..offset + Math.min(50, total - offset) - 1]

  mockServer = ->
    serverLocalhost
      .post '/listings/upsert'
      .reply 200

  runTest = (amountPages, done) ->
    status = count : 0
    SellerListingsUpdater.process (err) -> 
      done(err) if err
      status.count++

    setTimeout (->
      status.count.should.be.eql amountPages
      done()), 2000

  it 'should be get a once page and creates', (done) ->
    mockML 0, 30
    mockServer()
    runTest 1, done

