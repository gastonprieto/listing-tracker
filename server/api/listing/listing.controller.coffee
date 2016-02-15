_ = require('lodash')
Listing = require("./listing.model")

updateListing = (listing, newListing, callback) ->
  newQuantity = newListing.sold_quantity - listing.initial_sold_quantity
  return callback null if listing.quantity = newQuantity
  listing.quantity = newQuantity
  listing.save callback

newListing = (listing) ->
  _.merge listing, initial_sold_quantity: listing.sold_quantity

send = (res, next) ->
  (err, response) ->
      return next(err) if err
      res.json response

findOne = (listing, next, callback) ->
  Listing.findByListing listing.listing_id, (err, listing) ->
    return next(name: 'NotFound') if not err and not listing?
    callback(err, listing)

exports.getAll = (req, res, next) ->
  Listing.find {}, send(res, next)

exports.getOne = (req, res, next) ->
  findOne req.params, next, send(res, next)

exports.create = (req, res, next) ->
  Listing.create newListing(req.body), send(res, next)

exports.update = (req, res, next) ->
  findOne req.params, next, (err, listing) ->
    return next(err) if err
    updateListing listing, req.body, (err) ->
      send(res, next)(err, listing)
