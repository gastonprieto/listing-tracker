_ = require('lodash')
async = require('async')
request = require('request')

ml_host = 'https://api.mercadolibre.com:443'
server = 'http://localhost:9000'
seller_id = 154901871
req_max = 5
page_limit = 50

getArticlesBySeller = (seller_id, offset, limit, callback) ->
  request
    uri: ml_host + "/sites/MLM/search?seller_id=#{seller_id}&offset=#{offset}&limit=#{page_limit}"
    method: 'GET'
    json: true
    callback

saveArticles = (articles, callback) ->
  request
    url: server + '/listings/upsert'
    method: 'POST'
    json: true
    body: articles
    callback

newPage = (page, offset) -> 
  seller_id: seller_id
  offset: offset
  limit: page_limit
  page: page

processPage = (queue, task, callbacks) ->
  callbacks.start(task)
  queue.push task,
    (err) ->
      res = task.res
      maxElement = res.paging.offset + res.results.length
      processPage queue, (newPage (task.page + 1), maxElement), callbacks if maxElement != res.paging.total

      articles = _.map res.results, (result) ->
        _.defaults _.pick(result, ['title', 'seller_id', 'sold_quantity']), (listing_id: result.id, seller_id: res.seller.id)
      
      saveArticles articles, (err, res) ->
        callbacks.finish(err, task)

exports.process = (callbacks) ->
  
  queue = async.queue (task, callback) ->
    getArticlesBySeller task.seller_id, task.offset, task.limit, (err, res) ->
      task.res = res.body if not err
      callback(err)
    , req_max

  processPage queue, (newPage 0, 0), callbacks

  
