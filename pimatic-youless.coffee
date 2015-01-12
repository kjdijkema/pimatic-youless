# #Plugin pimatic-youless

module.exports = (env) ->

  Promise = env.require 'bluebird'
  
  assert = env.require 'cassert'

  class Youless extends env.plugins.Plugin

    init: (app, @framework, @config) =>      

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("Youlessdevice", {
        configDef: deviceConfigDef.Youlessdevice,
        createCallback: (config) => new Youlessdevice(config)
      })      

  class Youlessdevice extends env.devices.Device

    attributes:
      actualusage:
        description: "Actual usage"
        type: "number"
        unit: ' Watt'
      counter:
        description: "Total energy count"
        type: "number"
        unit: ' kWh'

    actualusage: 0.0
    counter: 0.0

    constructor: (@config) ->
      @id = config.id
      @ip = config.ip
      @name = config.name
      @timeout = config.timeout
      super()


      @requestData()
      setInterval( =>
        @requestData()
      , @timeout
      )

    http = require "http"

    data = 
        actualusage : ""
        counter : ""

    fetchData = (host, path, callback) ->
      options = 
          host: host
          path: path
      req = http.get options, (res) ->
          contents = ""
          res.on 'data', (chunk) ->
              contents += "#{chunk}"
          res.on 'end', () ->
              try contents = JSON.parse contents
              catch e 
                env.logger.error("Error retrieving Youless data") 
                return false 
              data.actualusage = contents.pwr
              data.counter = contents.cnt  
          res.on 'error', (err) ->    
              env.logger.error(err.message) 
      req.on 'socket', (socket) ->
          socket.setTimeout(30000)
          socket.on 'timeout', () ->    
              env.logger.error("Timeout retrieving Youless data")    
              req.abort
               

    requestData: () =>
      fetchData @ip,"/a?f=j"
      splittedcounter = data.counter.split(",")
      counter = splittedcounter[0]    
      @emit "actualusage", Number data.actualusage
      @emit "counter", Number counter
   

    getActualusage: -> Promise.resolve @actualusage
    getCounter: -> Promise.resolve @counter

  plugin = new Youless
  return plugin
