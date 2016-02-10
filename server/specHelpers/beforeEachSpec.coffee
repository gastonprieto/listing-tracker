Promise = require("bluebird")
connection = require("mongoose").connection
_ = require("lodash")

# Clean all the db
beforeEach ->

  $cleanCollections = _(connection.collections)
    .mapValues (it) => Promise.promisifyAll(it); it.removeAsync()
    .values()
    .value()

  Promise.all $cleanCollections
