
# The fixme Factory
#------------------
# Exports a createDemo() method which instantiates a Demo instance.

Demo = require("coffeecherries/fixme/demo")

Factory = 
  createDemo: ->
    return new Demo()

module.exports = Factory
