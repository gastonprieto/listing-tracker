###*
Main application routes
###
errors = require("./components/errors")

module.exports = (app) ->
  # Insert routes below
  app.use "/api/listings", require("./api/listing")

  # --- PUT MORE ROUTES HERE ---
  # All undefined asset or api routes should return a 404
  app.route("/:url(api|components|app|bower_components|assets)/*").get errors[404]