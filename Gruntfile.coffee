require("coffee-script/register")
#[^] last version of coffee

# To debug with web-client:
# export NODE_ENV=
# Find "livereload" and put false in the boolean variables.
# In express:dev task, put debug: false
# In server.js put 9001 as port or export PORT=9001

module.exports = (grunt) ->
  # Load grunt tasks automatically, when needed
  require("jit-grunt") grunt,
    express: "grunt-express-server"

  # Time how long tasks take. Can help when optimizing build times
  require("time-grunt") grunt

  # Define the configuration for all the tasks
  grunt.initConfig {

  # Project settings
    pkg: grunt.file.readJSON("package.json")
    yeoman:
    # configurable paths
      server: "server"

    express:
      options:
        port: process.env.PORT or 9000
        #opts: ['node_modules/.bin/coffee']
        #uncomment if the "script" property needs to be compiled with coffee
        #                    |
        #                    |
      dev: #                 |
        options: #           v
          script: "server/server.js"
          debug: true

      prod:
        options:
          script: "dist/server/server.js"

    open:
      server:
        url: "http://localhost:<%= express.options.port %>"

    watch:
      mochaTest:
        files: ["server/**/*.spec.coffee"]
        tasks: [
          "env:test"
          "mochaTest"
        ]

      gruntfile:
        files: ["Gruntfile.coffee"]

      express:
        files: ["server/**/*.{coffee,json}"]
        tasks: [
          "express:dev"
          "wait"
        ]
        options:
          livereload: true
          nospawn: true #Without this option specified express won't be reloaded


  # Make sure code styles are up to par and there are no obvious mistakes
    jshint:
      options:
        jshintrc: "<%= yeoman.client %>/.jshintrc"
        reporter: require("jshint-stylish")

      server:
        options:
          jshintrc: "server/.jshintrc"

        src: [
          "server/**/*.js"
          "!server/**/*.spec.js"
        ]

      serverTest:
        options:
          jshintrc: "server/.jshintrc-spec"

        src: ["server/**/*.spec.js"]

  # Debugging with node inspector
    "node-inspector":
      custom:
        options:
          "web-host": "localhost"


  # Use nodemon to run server in debug mode with an initial breakpoint
    nodemon:
      debug:
        script: "server/server.js"
        options:
          nodeArgs: ["--debug-brk"]
          env:
            PORT: process.env.PORT or 9000

          callback: (nodemon) ->
            nodemon.on "log", (event) ->
              console.log event.colour

            # opens browser on initial server start
            nodemon.on "config:update", ->
              setTimeout (->
                require("open") "http://localhost:8080/debug?port=5858"
              ), 500

  # Run some tasks in parallel to speed up the build process
    concurrent:
      debug:
        tasks: [
          "nodemon"
          "node-inspector"
        ]
        options:
          logConcurrentOutput: true

  # Test settings
    mochaTest:
      options:
        reporter: "spec"

      src: ["server/srv-globals.js", "server/specHelpers/beforeEachSpec.coffee", "server/**/*.spec.coffee", "jobs/**/*.spec.coffee"]

    protractor:
      options:
        configFile: "protractor.conf.js"

      chrome:
        options:
          args:
            browser: "chrome"

    env:
      test:
        NODE_ENV: "test"

      prod:
        NODE_ENV: "production"

  }

  # Used for delaying livereload until after server has restarted
  grunt.registerTask "wait", ->
    grunt.log.ok "Waiting for server reload..."
    done = @async()
    setTimeout (->
      grunt.log.writeln "Done waiting!"
      done()
    ), 1500

  grunt.registerTask "express-keepalive", "Keep grunt running", ->
    @async()

  grunt.registerTask "serve", (target) ->
    if target is "dist"
      return grunt.task.run([
        "build"
        "env:prod"
        "express:prod"
        "wait"
        #"open"
        "express-keepalive"
      ])

    if target is "debug"
      return grunt.task.run([
        "concurrent:debug"
      ])

    return grunt.task.run [
      "express:dev"
      "wait"
      #"open"
      "watch"
    ]

  grunt.registerTask "server", ->
    grunt.log.warn "The `server` task has been deprecated. Use `grunt serve` to start a server."
    grunt.task.run ["serve"]

  grunt.registerTask "test", (target) ->
    if target is "server"
      return grunt.task.run [
        "env:test"
        "mochaTest"
      ]

    grunt.task.run [
      "test:server"
    ]

  grunt.registerTask "build", [
    "concurrent:dist"
  ]

  grunt.registerTask "default", "serve"
