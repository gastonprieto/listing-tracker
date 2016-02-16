_ = require('lodash')
async = require('async')
request = require('request')

ml_host = 'https://api.mercadolibre.com'
server = 'http://localhost:9000'
seller_id = 154901871

getArticlesBySeller = (seller_id, offset, limit, callback) ->
  request
    url: ml_host + '/sites/MLM/search',
    method: 'GET',
    json: true,
    qs:
      seller_id: seller_id
      offset: offset,
      limit: limit,
    callback

saveArticles = (articles, callback) ->
  request
    url: server + '/listings/upsert',
    method: 'POST',
    json: true,
    body: articles,
    callback

exports.process = (callback) ->
  getArticlesBySeller seller_id, 0, 50, (err, res) ->
    articles = _.map res.body.results, (result) ->
      _.defaults _.pick(result, ['title', 'seller_id', 'sold_quantity']), listing_id: result.id
    
    saveArticles articles, (err, res) ->
      callback(err)
