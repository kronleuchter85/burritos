'use strict';
module.exports = function(app) {
  var todoList = require('./controller.js');
	var express = require('express');
  
	app.route('/get_all_records/:tableId').get(todoList.getAllRecordsTape);
	

	app.route('/get_trades_by_datetime_range').post(todoList.getTradesByDateTimeRanges);



	app.route('/labels/')
		.get(todoList.getAllLabels);
	
	app.route('/labels/:labelId')
		.get(todoList.find_labels_by_id);
		
	app.route('/labels/intervals/')
		.post(todoList.add_intervals_to_label);
	
};


