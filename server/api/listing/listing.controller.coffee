Listing = require("./listing.model")

send = (res, next) ->
  (err, response) ->
      return next(err) if err
      res.json response

findOne = (req, next, callback) ->
  Listing.findOne { listing_id: req.params.listing_id }, (err, listing) ->
    return next(name: 'NotFound') if not err and not listing?
    callback(err, listing)

exports.getAll = (req, res, next) ->
  Listing.find {}, send(res, next)

exports.getOne = (req, res, next) ->
  findOne req, next, send(res, next)

exports.create = (req, res, next) ->
  listing = req.body
  listing.initial_sold_quantity = req.body.sold_quantity

  Listing.create listing, send(res, next)

exports.update = (req, res, next) ->
  findOne req, next, (err, listing) ->
    return next(err) if err
    newQuantity = req.body.sold_quantity - listing.initial_sold_quantity
    return res.json listing if listing.quantity = newQuantity
    listing.quantity = newQuantity
    listing.save (err) ->
      send(res, next)(err, listing)
