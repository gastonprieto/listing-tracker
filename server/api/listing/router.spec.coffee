_ = require('lodash')
should = require("chai").should()
request = require('supertest')
app = include('app').app
Listing = require('./listing.model')

describe 'Listing', ->

  requestGetAll = ->
    request(app)
      .get('/listings')

  samsung =
    listing_id: "MLA1111"
    title: "Samsung Galaxy"
    seller_id: 1234
    initial_sold_quantity: 12
    quantity: 0

  iphoneRequest =
    listing_id: "MLA1234"
    title: "iPhone 6s 32GB"
    seller_id: 1234
    sold_quantity: 20 

  beforeEach (done) ->
    Listing.create samsung, done

  describe 'POST /listings', ->
    it 'should create the listing with the given sold_quantity as the initial_sold_quantity', (done) ->
      request(app)
        .post('/listings')
        .send(iphoneRequest)
        .expect 200, {
          listing_id: "MLA1234"
          title: "iPhone 6s 32GB"
          seller_id: 1234
          initial_sold_quantity: 20
          quantity: 0
        }, done

    it 'should return 400 Bad Request when a required property is missing', (done) ->
      data =
        title: "iPhone 6s 32GB",
        seller_id: 1234,
        sold_quantity: 20

      request(app)
        .post('/listings')
        .send(data)
        .expect 400, done

  describe 'GET /listings', ->
    it 'should return all the listings', (done) ->
      requestGetAll()
        .expect 200, [samsung], done

  describe 'GET /listings/:listing_id', ->
    it 'should return the requested listing', (done) ->
      request(app)
        .get('/listings/MLA1111')
        .expect 200, samsung, done

    it 'should return 404 Not Found when the requested listing does not exist', (done) ->
      request(app)
        .get('/listings/WRONGID')
        .expect 404, done

  describe 'PUT /listings/:listing_id', ->
    it 'should update the listing incrementing the quantity with the difference between the current sold_quantity and the initial_sold_quantity', (done) ->
      data =
        sold_quantity: 14

      request(app)
        .put('/listings/MLA1111')
        .send(data)
        .expect 200, {
          listing_id: "MLA1111"
          title: "Samsung Galaxy"
          seller_id: 1234
          initial_sold_quantity: 12
          quantity: 2
        }, done

    it 'should return 404 Not Found when the requested listing does not exist', (done) ->
      request(app)
        .put('/listings/WRONGID')
        .send({})
        .expect 404, done

  describe 'POST /listings/upsert', ->
    checkListings = (validation, next) ->
      requestGetAll()
        .expect 200
        .end (err, res) -> 
          return next(err, null) if err
          validation(res.body)
          next()

    
    it 'should create a new listing if it does not exists', (done) ->
      toCreated = _.times 20, (i) -> 
        listing_id: "MLA" + i
        seller_id: 1
        title: "foo" + i
        sold_quantity: 30

      request(app)
        .post('/listings/upsert')
        .send(toCreated)
        .expect 200
        .end (err) ->
          return done(err) if err
          checkListings ((listings) -> listings.should.have.length(1 + toCreated.length)), done
              

    it 'should update the listing if it exists', (done) ->
      data = 
        listing_id: "MLA1111"
        sold_quantity: 20

      request(app)
        .post('/listings/upsert')
        .send([data])
        .expect 200
        .end (err) ->
          return done(err) if err
          checkListings ((listings) ->
              listings.should.have.length(1)
              listings[0].quantity.should.be.eql(8)
            ), done

    it 'should return 400 if the request has 50 or more listings', (done) ->
      data = _.times 51, (i) -> 
        listing_id: "MLA" + i
        sold_quantity: 20

      request(app)
        .post('/listings/upsert')
        .send(data)
        .expect (res) ->
          res.body.should.have.property('error')
          null
        .expect 400, done
