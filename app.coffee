css_pipeline = require 'css-pipeline'
browserify = require 'roots-browserify'

module.exports =
  ignores: ['readme.md', '**/layout.*', '**/_*', '.gitignore', 'ship.*conf']

  extensions: [
    browserify(files: 'assets/js/main.coffee', out: 'js/main.js'),
    css_pipeline(files: 'assets/css/*.styl')
  ]

  stylus:
    use: []
    sourcemap: true

  'coffee-script':
    sourcemap: true

  jade:
    pretty: true
