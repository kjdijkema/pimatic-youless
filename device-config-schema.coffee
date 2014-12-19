module.exports ={
  title: "pimatic-youless device config schemas"
  Youlessdevice: {
    title: "Youlessdevice config options"
    type: "object"
    properties: 
      ip:
        description: "Youless IP-ddress"
        format: String
        default: "10.0.0.0"
      timeout:
        description: "Timeout between requests"
        format: Number
        default: "60000"      
  }
}  