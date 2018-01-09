'use strict';


//var mongoose = require('mongoose');
//var Label = mongoose.model('Labels');
var pg = require('pg');
var util = require('util');

//var connectionString = 'postgres://postgres:postgres@192.168.1.3:5432/gtrader';
var connectionString = 'postgres://postgres:postgres@localhost:5432/ds';
	
exports.getAllRecordsTape = function(req, res) {
 
	var results = [];
	var tableName = req.params.tableId
	console.log('getAllRecordsTape ' + tableName);
	
	pg.connect(connectionString, (err, client, done) => {
		
		if(err) {
		  done();
		  console.log(err);
		  return res.status(500).json({success: false, data: err});
		}
		
		const query = client.query("select * from " + tableName + " limit 500");
		
		query.on('row', (row) => {
		  results.push(row);
		});
		
		query.on('end', function() {
		  done();
		  			
		  return res.json(results);
		});
	});

};



exports.getTradesByDateTimeRanges = function(req,res){
	

	var queryString = "select * from @table " + 
		"where (event_type = 'TRADE') and ((event_date + event_time) between (date '@minDate' + time '@minTime' ) and ( date '@maxDate' + time '@maxTime'))";
	
	var params = req.body;
	
	console.log('recibiendo params: ' + util.inspect(params));
	queryString = queryString.replace(/@table/g,params.table);
	queryString = queryString.replace(/@minDate/g,params.minDate);
	queryString = queryString.replace(/@minTime/g,params.minTime);
	queryString = queryString.replace(/@maxDate/g,params.maxDate);
	queryString = queryString.replace(/@maxTime/g,params.maxTime);
	
	console.log('queryString: ' + queryString);
	
	
	var results = [];
	
	pg.connect(connectionString, (err, client, done) => {
		
		if(err) {
		  done();
		  console.log(err);
		  return res.status(500).json({success: false, data: err});
		}
		
		const query = client.query(queryString);
		
		query.on('row', (row) => {
		  results.push(row);
		});
		
		query.on('end', function() {
		  done();
		  			
		  return res.json(results);
		});
	});
	
};


exports.getAllLabels = function(req, res) {
 
	console.log('getAllLabels');

	Label.find({}, function(err, j) {
		if (err)
		  res.send(err);
	  
	  
	  
		res.json(j);
	});
  
};




exports.find_labels_by_id = function(req, res) {
	
	console.log('find labels by id ' + req.params.labelId);
	Label.find({name: req.params.labelId}, function(err, task) {
		if (err)
		  res.send(err);
	  
		console.log('devolviendo:');
		console.log(util.inspect(task));
		res.json(task);
	});
};



exports.add_intervals_to_label = function(req, res) {
	
	console.log('add_intervals_to_label');
	console.log('-------------------------------------------------------------');
	var request = req.body;
	var newIntervals = request.intervals;
	console.log('intervalos: ' + util.inspect(newIntervals));
	console.log('-------------------------------------------------------------');
	Label.find({table: request.name}, function(err, lbl) {
		if (err)
		  res.send(err);

		if( typeof lbl == 'undefined' || lbl.length == 0){
						
			console.log('no existe label previo asi q se crea uno');
			console.log('-------------------------------------------------------------');
			
			var new_Label = new Label(request);
						
			new_Label.save(function(err, lbl) {
				if (err)
				  res.send(err);
				res.json(request);
			});
			
		}else{
			
			console.log('El label existe asi qe se agregan los nuevos intervalos');
			console.log('-------------------------------------------------------------');
			var currentLabel = lbl[0];			
			
			newIntervals.forEach(function(i){
				currentLabel.intervals.push(i);
			});
			
			currentLabel.save(function(err, lbl) {
				if (err)
				  res.send(err);
			
				console.log('actualizacion terminada: ' + currentLabel);
				console.log('-------------------------------------------------------------');
				
			});	
		}
	
  });
};



