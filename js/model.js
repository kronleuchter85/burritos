
'use strict';
var mongoose = require('mongoose');
var Schema = mongoose.Schema;


var Label = new Schema({
  name: String,
  table: String ,
  outputName: String,
  maxDate: String,
  maxTime: String,
  minDate: String,
  minTime: String,
  intervals: Array,
  requireAdvances: Boolean
});

module.exports = mongoose.model('Labels', Label);