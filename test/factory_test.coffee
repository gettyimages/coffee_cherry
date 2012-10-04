
describe "The fixme Factory", ->

  beforeEach ->
    @fixmeFactory = require('coffeecherries/fixme/factory')

  it "should be defined", ->
    @fixmeFactory.should.exist

  it "should have a createDemo function", ->
    @fixmeFactory.createDemo.should.exist

  it "should be able to add two numbers via createDemo", ->
    demo = @fixmeFactory.createDemo()
    demo.add(93, 7).should.equal 100
