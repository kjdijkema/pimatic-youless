pimatic-youless
===============

Reading Youless Energy monitor and showing values in pimatic

v0.4.0 


Configuration
-------------
Add the plugin to the plugin section of your config.json:

    {
      "plugin": "youless"
    }

Add a device to the devices section:

    {
      "id": "youless",
      "name": "Energy consumption",
      "class": "Youlessdevice",
      "ip": "10.0.0.14",
      "timeout": 60000
    }

ip = IP-address of your Youless device

timeout = time between readings in milliseconds

Make sure your Youless is not password-protected.