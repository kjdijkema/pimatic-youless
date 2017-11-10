Note: this plugin is no longer maintained by me. Feel free to fork or pull!

pimatic-youless
===============

Reading Youless Energy monitor and showing values in pimatic

v0.5 (should now work with pimatic v0.9)


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
