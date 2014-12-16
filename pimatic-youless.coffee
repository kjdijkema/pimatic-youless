# #Plugin pimatic-youless

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  convict = env.require "convict"  

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  class Youless extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      #env.logger.info("Started Youless plugin")

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("Youlessdevice", {
        configDef: deviceConfigDef.Youlessdevice,
        createCallback: (config) => new Youlessdevice(config)
      })      

  class Youlessdevice extends env.devices.Device

    attributes:
      usage:
        description: "Actual usage"
        type: "number"
        unit: ' Watt'

    usage: 0.0

    constructor: (@config) ->
      @id = config.id
      @ip = config.ip
      @name = config.name
      @timeout = config.timeout
      super()

      @requestUsage()
      setInterval( =>
        @requestUsage()
      , @timeout
      )

    # requestUsage: () =>
    #   youlessLib.find
    #     search: @ip
    #   , (err, result) =>
    #     env.logger.error("Error retrieving Youless data") if err
    #     if result
    #       @emit "usage", Number result[0].current.usage

    requestUsage: () =>
      @emit "usage", Number 33          

    getUsage: -> Promise.resolve @usage

  # ###Finally
  # Create a instance of my plugin
  plugin = new Youless
  # and return it to the framework.
  return plugin
