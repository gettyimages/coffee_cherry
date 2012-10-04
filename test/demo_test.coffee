
Demo = require('coffeecherries/fixme/demo')

describe "Demo", ->

  beforeEach ->
    @demo = new Demo()

  it "should add two numbers", ->
    @demo.add(21, 34).should.equal 55
