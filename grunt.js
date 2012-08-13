/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',
    meta: {
      banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */'
    },
    coffee: {
      app: {
        src: '<config:concat.coffee.dest>',
        dest: 'public/js',
        options: {
            bare: true
        }
      }
    },
    concat: {
      finalize: {
        src: [
          '<banner:meta.banner>',
          'public/js/libs/jquery.js',
          'public/js/libs/jquery.mousewheel.js',
          'public/js/libs/jquery.jscrollpane.js',
          'public/js/libs/json2.js',
          'public/js/libs/spin.js',
          'public/js/libs/underscore.js',
          'public/js/libs/backbone.js',
          'public/js/libs/viewporter.js',
          'public/js/<%= pkg.name %>.js'
        ],
        dest: 'public/js/application.js'
      },
      coffee: {
        src: [
          'public/js/app/models/*.coffee',
          'public/js/app/collections/*.coffee',
          'public/js/app/views/*.coffee',
          'public/js/app/*.coffee'
        ],
        dest: 'public/js/<%= pkg.name %>.coffee'
      }
    },
    min: {
      dist: {
        src: ['<banner:meta.banner>', '<config:concat.finalize.dest>'],
        dest: 'public/js/application.min.js'
      }
    },
    watch: {
      coffee: {
        files: '<config:concat.coffee.src>',
        tasks: 'concat:coffee coffee concat:finalize min'
      }
    },
    uglify: {}
  });

  grunt.loadNpmTasks('grunt-coffee');


  // Default task.
  grunt.registerTask('default', 'coffee concat min');

};
