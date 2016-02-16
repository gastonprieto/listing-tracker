require("coffee-script/register");
require("./src/run.coffee").process({
  start: function (task) {
    console.log('Start page', task.page);
  },
  finish: function (err, task) {
    console.log('Finish page', task.page);
  }
})
