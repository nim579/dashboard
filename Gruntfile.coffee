module.exports = (grunt)->
    
    grunt.loadNpmTasks 'grunt-bower-concat'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.initConfig
        bower_concat:
            dev:
                dest: 'test/static/libs.js'
                cssDest: 'test/static/libs.css'
                dependencies:
                    backbone: ['jquery', 'underscore']

        coffee:
            dev:
                options:
                    bare: true

                files:
                    './test/static/app.js': ['./src/**/*.coffee']
                    './test/static/widgets.js': ['./widgets/**/*.coffee']

            build:
                options:
                    bare: true

                files:
                    './lib/dashboard.js': ['./src/**/*.coffee', './widgets/**/*.coffee']

        less:
            dev:
                options:
                    paths: ['./']

                files:
                    './test/static/app.css': ['./src/styles/global.less', './widgets/**/*.less']

            build:
                options:
                    paths: ['./src/styles']

                files:
                    './lib/dashboard.css': ['./src/styles/global.less', './widgets/**/*.less']

        watch:
            coffee:
                files: ['./src/**/*.coffee', './widgets/**/*.coffee']
                tasks: ['coffee:dev']

            less:
                files: ['./src/styles/**/*.less', './widgets/**/*.less']
                tasks: ['less:dev']


    grunt.registerTask 'compile', 'Compile project', ['bower_concat:dev', 'coffee:dev', 'less:dev']
    grunt.registerTask 'build', 'Build project for production', ['coffee:build', 'less:build']

