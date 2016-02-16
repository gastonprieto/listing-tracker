_ = require('lodash')
nock = require('nock')
should = require("chai").should()
SellerListingsUpdater = require('./run')

describe 'SellerListingsUpdater', ->

  serverML = nock('https://api.mercadolibre.com')
  serverLocalhost = nock('http://localhost:9000')

  beforeEach = ->
    nock.disableNetConnect()

  afterEach = ->
    nock.cleanAll();
    nock.enableNetConnect()

  mockML = (result) ->
    serverML
      .get '/sites/MLM/search'
      .query
        limit: 50,
        offset: 0,
        seller_id: 154901871
      .reply 200, result

  mockServer = ->
    serverLocalhost
      .post '/listings/upsert'
      .reply 200

  items = _.times 180, (i) ->
    id: 'MLM' + i,
    seller_id: 154901871,
    title: 'title' + i,
    sold_quantity: i

  it 'should be create listing when exist one page', (done) ->
    mockML 
      paging: 
        total: 30,
        offset: 0,
        limit: 50
      results:
        _.take items, 30

    mockServer()

    SellerListingsUpdater.process (err) ->
      serverML.done()
      serverLocalhost.done()
      done(err) 


    