var express = require('express');
var path = require('path');
var app = express();

var WebSocket = require('ws');

//var mongoose = require('mongoose');

var pg = require('pg');

var Task = require('./model.js');
var bodyParser = require('body-parser');

app.use(bodyParser.json({limit: "50mb"}));
app.use(bodyParser.urlencoded({limit: "50mb", extended: true, parameterLimit:50000}));

//mongoose.Promise = global.Promise;
//mongoose.connect('mongodb://localhost/DS'); 

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.set('port', 4000);
app.use(express.static(path.join(__dirname, 'public')));


var routes = require('./routes.js'); //importing route
routes(app); //register the route


// Listen for requests
var server = app.listen(app.get('port'), function() {
  var port = server.address().port;
  console.log('Magic happens on port ' + port);
  
  


	const ws = new WebSocket('ws://api.bitfinex.com/ws/');

	ws.on('open', function open() {
		//ws.send('something');
	});

	ws.on('message', function incoming(data) {
		console.log(data);
	});
	  
});


