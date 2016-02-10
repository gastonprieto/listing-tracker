path = require("path")

try
  require("./" + process.env.NODE_ENV)
catch e
  # ...


# All configurations will extend these options
# ============================================
module.exports =
  env: process.env.NODE_ENV

  # Root path of server
  root: path.normalize(__dirname + "/../../..")

  # Server port
  port: process.env.PORT or 9000

  # Should we populate the DB with sample data?
  seedDB: false

  # Secret for session, you will want to change this and make it an environment variable
  secrets:
    session: process.env.SESSION_SECRET or "listing-tracker-secret"

  # MongoDB connection options
  mongo:
    uri: process.env.MONGO_URI
    options:
      db:
        safe: true
