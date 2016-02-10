should = require("chai").should()
request = require('supertest')
app = include('app').app
Listing = require('./listing.model')

describe 'Listing', ->
  samsung =
    listing_id: "MLA1111"
    title: "Samsung Galaxy"
    seller_id: 1234
    initial_sold_quantity: 12
    quantity: 0

  beforeEach (done) ->
    Listing.create samsung, done

  describe 'POST /api/listings', ->
    it 'should create the listing with the given sold_quantity as the initial_sold_quantity', (done) ->
      data =
        listing_id: "MLA1234"
        title: "iPhone 6s 32GB"
        seller_id: 1234
        sold_quantity: 20

      request(app)
        .post('/api/listings')
        .send(data)
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
        .post('/api/listings')
        .send(data)
        .expect 400, done

  describe 'GET /api/listings', ->
    it 'should return all the listings', (done) ->
      request(app)
        .get('/api/listings')
        .expect 200, [samsung], done

  describe 'GET /api/listings/:listing_id', ->
    it 'should return the requested listing', (done) ->
      request(app)
        .get('/api/listings/MLA1111')
        .expect 200, samsung, done

    it 'should return 404 Not Found when the requested listing does not exist', (done) ->
      request(app)
        .get('/api/listings/WRONGID')
        .expect 404, done

  describe 'PUT /api/listings/:listing_id', ->
    it 'should update the listing incrementing the quantity with the difference between the current sold_quantity and the initial_sold_quantity', (done) ->
      data =
        sold_quantity: 14

      request(app)
        .put('/api/listings/MLA1111')
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
        .put('/api/listings/WRONGID')
        .send({})
        .expect 404, done
