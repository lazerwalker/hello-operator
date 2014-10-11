serialport = require("serialport");
SerialPort = serialport.SerialPort
serial = new SerialPort "/dev/tty.usbserial-A5025WB7",
  parser: serialport.parsers.readline '\r'

serial.on "open", =>
  serial.on "data", (data) =>
    console.log JSON.parse(data)
