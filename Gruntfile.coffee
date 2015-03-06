module.exports = (grunt)->
    
    grunt.loadNpmTasks 'grunt-bower-concat'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'

    grunt.initConfig
        bower_concat:
            dev:
                dest: 'test/static/libs.js'
                cssDest: 'test/static/libs.css'

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
                    './test/static/app.css': ['./src/styles/global.less']

            build:
                options:
                    paths: ['./src/styles']

                files:
                    './lib/dashboard.css': ['./src/styles/global.less']


    grunt.registerTask 'compile', 'Compile project', ['bower_concat:dev', 'coffee:dev', 'less:dev']
    grunt.registerTask 'build', 'Build project for production', ['coffee:build', 'less:build']

