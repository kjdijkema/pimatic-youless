# #Plugin pimatic-youless

module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  http = require "http"
  
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
      @id = @config.id
      @ip = @config.ip
      @name = @config.name
      @timeout = @config.timeout
      super()


      @requestData()
      setInterval( =>
        @requestData()
      , @timeout
      )

    

    fetchData = (host, path, callback) ->
      data = 
        actualusage : ""
        counter : ""
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
            callback(data)
        res.on 'error', (err) ->    
            env.logger.error(err.message)  
      req.on 'error', (err) ->
          if err.code == 'ETIMEDOUT' 
              env.logger.error("Timeout retrieving Youless data")
          else 
              env.logger.error("Error retrieving Youless data: #{err}")  

    
               
    requestData: () =>
      fetchData @ip,"/a?f=j", (data) =>
        splittedcounter = data.counter.split(",")
        counter = splittedcounter[0]
        @actualusage = Number data.actualusage
        @counter = Number counter
        @emit "actualusage", @actualusage
        @emit "counter", @counter
   

    getActualusage: -> Promise.resolve @actualusage
    getCounter: -> Promise.resolve @counter

  plugin = new Youless
  return plugin
