
module.exports = (app) ->
  app.use (err, req, res, next) ->
    return next() if not err?
    switch err.name
      when "NotFound"
        res.sendStatus 404
      when "ValidationError"
        res.status(400).send err
      else
        res.status(500).send err
