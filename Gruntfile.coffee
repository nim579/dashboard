module.exports = (grunt)->
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'node-srv'

    grunt.initConfig
        browserify:
            options:
                transform: [
                    'coffeeify'
                    'pugify'
                ]
                browserifyOptions:
                    bare: true
                    extensions: ['.coffee', '.pug', '.js']

            dev:
                files:
                    "dev/dashboard.js": ["browser.coffee"]

            module:
                files:
                    "lib/dashboard.js": ["./src/index.coffee"]

            browser:
                files:
                    "app/dashboard.js": ["browser.coffee"]

        less:
            dev:
                files:
                    'dev/dashboard.css': ['src/styles/index.less', 'src/widgets/**/*.less']

            module:
                files:
                    'lib/dashboard.css': ['src/styles/index.less', 'src/widgets/**/*.less']

            browser:
                files:
                    'app/dashboard.css': ['src/styles/index.less', 'src/widgets/**/*.less']

        watch:
            coffee:
                files: ['./src/**/*.coffee', './src/**/*.pug']
                tasks: ['browserify:dev']

            less:
                files: ['./src/**/*.less']
                tasks: ['less:dev']

        srv:
            dev:
                port: 8000
                root: './dev'


    grunt.registerTask 'dev', 'Run project for dev', ->
        grunt.config.data.srv.dev.keepalive = false
        grunt.task.run ['browserify:dev', 'less:dev', 'srv:dev', 'watch']

    grunt.registerTask 'module', 'Build project like npm module', ['browserify:module', 'less:module']
    grunt.registerTask 'browser', 'Build project for browser useage', ['browserify:browser', 'less:browser']
