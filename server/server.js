require("./srv-globals");

var app = require("./app.coffee");

app.server.listen(app.port, app.ip, function() {
  console.log("Express server listening on %d, in %s mode", app.port, app.env);
});
