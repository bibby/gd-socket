extends Node

var socket = StreamPeerTCP.new()
var _accum = 0  # delta accumulator
var _active = false   # socket intended for use
var _connected = false  # socket is connected

const ERR = 1

export(String) var host = "localhost"
export(int) var port = 7777

func _ready():
	set_process(true)
	
func _process(delta):
	_readloop(delta)	

func write(string):
	if(_connected):
		socket.write(_string_to_raw_array(string))

func connect():
	_active = true
	var err = socket.connect(host, port)
	_connected = socket.is_connected()
	return err

func disconnect():
	_active = false
	_connected = false
	socket.disconnect()

func _readloop(delta):
	if(not _active):
		pass
		
	# TODO, emit errors and data
	accum += delta
	
	if(accum > 1):
		accum = 0
		var connected = socket.is_connected()
		
		if(not connected):
			_respond("Lost Connection", ERR)
		else:
			var output = socket.get_partial_data(1024)
			var errCode = output[0]
			var outputData = output[1]
			
			if(errCode != 0):
				_respond( "ErrCode:" + str(errCode), ERR)
			else:
				var outStr = outputData.get_string_from_utf8()
				if(outStr != ""):
					_respond( outStr, 0 )

func _respond(msg, errCode):
	if(errCode == 0):
		_respondOK(msg)
	elif(errCode == ERR):
		_respondErr(msg)

func _respondOK(msg):
	# TODO emit?
	pass

func _respondErr(msg):
	# TODO emit?
	pass
func _string_to_raw_array(string):
	var len = string.length()
	var raw = RawArray()
	var i=0
	
	while(i<len):
		raw.push_back( string.ord_at(i) )
		i=i+1
	
	return raw
