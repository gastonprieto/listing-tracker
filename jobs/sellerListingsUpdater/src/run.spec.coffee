_ = require('lodash')
nock = require('nock')
should = require("chai").should()
SellerListingsUpdater = require('./run')

describe 'SellerListingsUpdater', ->

  @.timeout(5000);

  serverML = nock('https://api.mercadolibre.com')

  serverLocalhost = nock('http://localhost:9000')
  seller_id = 154901871

  items = _.times 270, (i) ->
    id: 'MLM' + i,
    seller_id: seller_id,
    title: 'title' + i,
    sold_quantity: i


  beforeEach = ->
    nock.disableNetConnect()

  afterEach = ->
    nock.cleanAll();
    nock.enableNetConnect()

  mockML = (offset, total) ->
    serverML
      .get "/sites/MLM/search?seller_id=#{seller_id}&offset=#{offset}&limit=50"
      .reply 200,
        seller:
          id: seller_id
        paging:
          total: total,
          offset: offset,
          limit: 50
        results:
          items[offset..offset + Math.min(50, total - offset) - 1]

  mockServer = (times) ->
    serverLocalhost
      .post '/listings/upsert'
      .times times
      .reply 200

  runTest = (amountPages, done) ->
    status = count : 0
    SellerListingsUpdater.process 
      start: _.noop
      finish: (err) ->
        done(err) if err
        status.count++

    setTimeout (->
      status.count.should.be.eql amountPages
      done()), 2000

  it 'should be get a once page and creates', (done) ->
    mockML 0, 30
    mockServer(1)
    runTest 1, done

  it 'should be get multiples pages and create', (done) ->
    mockML 0, 270
    mockML 50, 270
    mockML 100, 270
    mockML 150, 270    
    mockML 200, 270
    mockML 250, 270

    mockServer(6)
    runTest 6, done
