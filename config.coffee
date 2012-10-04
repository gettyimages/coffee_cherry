exports.config =

  paths:
    app: 'coffeecherries'
    public: 'build'

  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'js/fixme.js': /^coffeecherries/
        'test/js/test.js': /^test(\/|\\)(?!vendor)/
        'test/js/test-vendor.js': /^test(\/|\\)(?=vendor)/

    stylesheets:
      joinTo:
        'test/stylesheets/test.css': /^test/

  minify: no
