_ = require('lodash')
async = require('async')
request = require('request')

ml_host = 'https://api.mercadolibre.com'
server = 'http://localhost:9000'
seller_id = 154901871
req_max = 5

getArticlesBySeller = (seller_id, offset, limit, callback) ->
  request
    url: ml_host + '/sites/MLM/search'
    method: 'GET'
    json: true
    qs:
      seller_id: seller_id
      offset: offset
      limit: limit
    callback

saveArticles = (articles, callback) ->
  request
    url: server + '/listings/upsert'
    method: 'POST'
    json: true
    body: articles
    callback

newPage = (offset) -> 
  seller_id: seller_id
  offset: offset
  limit: 50

processPage = (queue, task, pageCallback) ->
  queue.push task,
    (err) ->
      res = task.res
      maxElement = res.paging.offset + res.results.length
      processPage queue, ( seller_id: seller_id, offset: maxElement + 1, limit: 50 ), pageCallback if maxElement != res.paging.total

      articles = _.map res.results, (result) ->
        _.defaults _.pick(result, ['title', 'seller_id', 'sold_quantity']), listing_id: result.id
      
      saveArticles articles, (err, res) ->
        pageCallback(err)

exports.process = (pageCallback, finishCallback) ->
  
  queue = async.queue (task, callback) ->
    getArticlesBySeller task.seller_id, task.offset, task.limit, (err, res) ->
      task.res = res.body if not err
      callback(err)
    , req_max

  processPage queue, (newPage 0), pageCallback

  
