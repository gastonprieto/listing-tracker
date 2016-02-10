mongoose = require('mongoose')
_ = require('lodash')
Schema = mongoose.Schema

ListingSchema = new Schema
  listing_id:
    type: String
    required: true
    unique: true
  title:
    type: String
    required: true
  seller_id:
    type: Number
    index: true
    required: true
  initial_sold_quantity:
    type: Number
    required: true
  quantity:
    type: Number
    default: 0

ListingSchema.methods.toJSON = ->
  _.omit @toObject(), ['_id', '__v']

module.exports = mongoose.model 'Listing' , ListingSchema