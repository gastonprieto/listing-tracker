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

newPage = (page) -> 
  seller_id: seller_id
  offset: page * page_limit
  limit: page_limit
  page: page

savePage = (page, callback) ->
  articles = _.map page.results, (result) ->
    _.defaults _.pick(result, ['title', 'seller_id', 'sold_quantity']), (listing_id: result.id, seller_id: page.seller.id)
  
  saveArticles articles, (err, res) ->
    callback(err, page)

needProcessMorePages = (task, total) ->
  task.page == 0 && total > page_limit

generateNewPages = (queue, total, callbacks) ->
  amountPages = Math.ceil(total / page_limit)
  processPage queue, (newPage page), callbacks for page in [1..amountPages - 1]

processPage = (queue, task, callbacks) ->
  callbacks.start(task)
  queue.push task,
    (err) ->
      result = task.res
      generateNewPages queue, result.paging.total, callbacks if needProcessMorePages(task, result.paging.total)
      savePage result, callbacks.finish

exports.process = (callbacks) ->
  
  queue = async.queue (task, callback) ->
    console.log 'Start process queue\'s item'
    getArticlesBySeller task.seller_id, task.offset, task.limit, (err, res) ->
      task.res = res.body if not err
      console.log 'Finish process queue\'s item'
      callback(err)
    , req_max

  processPage queue, (newPage 0), callbacks

  
