

angular.module('todoController', [])
	.controller('mainController', ['$scope','$http', '$route' , '$routeParams' , '$location', 'Todos', function($scope, $http, $route, $routeParams, $location, Todos) {
		
		var params = $location.search();
		
		$scope.tableAsset = params['tableAsset'];
		$scope.labelName = params['labelName'];
		$scope.outputName = params['outputName'];
		$scope.maxDate = params['maxDate'];
		$scope.maxTime = params['maxTime'];
		$scope.minDate = params['minDate'];
		$scope.minTime = params['minTime'];		
		
		
		$scope.selectedIntervals = [];
		$scope.requireAdvances = false;
		
		$scope.getMax = function(points){
			var max = null;
			points.forEach(function(e){				
				if(max == null)
					max = e;
				if(e> max)
					max = e;	
			});
			return max;
		};
		
		$scope.getMin = function(points){
			var min = null;
			points.forEach(function(e){				
				if(min == null)
					min = e;
				if(e < min)
					min = e;	
			});
			return min;
		};
		
		$scope.get_roundingBox = function (x_points , y_points){			
			var x_max = $scope.getMax(x_points);
			var x_min = $scope.getMin(x_points);
			
			var y_max = $scope.getMax(y_points);
			var y_min = $scope.getMin(y_points);
		
			return {
				max_y: y_max,
				max_x: x_max,
				min_y: y_min,
				min_x: x_min
			};			
		};
			

		$scope.getSelectedPoints = function (box){
			var filtered = $scope.all_rows.filter(function(r){							
				var result = r.x >= box.min_x && r.x <= box.max_x && r.y <= box.max_y && r.y >= box.min_y;							
				return result;
			});
			return filtered;
		};


		$scope.render = function(rows){			
			$scope.all_rows = rows.map(function(e){				
				var obj = new Object();
				//obj.x = e['event_time'];
				obj.x = getFormatedDate(e['event_date']) + ' ' + e['event_time'];
				
				obj.y = e['event_price'];
				
				return obj;				
			});

			
			function getFormatedDate(date){
				
				var t_separator_index = date.indexOf('T');
				date = date.substring(0,t_separator_index);
			
				return date;
			}
			
			function unpackX(rows) {
			  return rows.map(function(row) { 
		
					return getFormatedDate(row['event_date']) + ' ' + row['event_time']; 
				});
			}
			
			function unpackY(rows) {
			  return rows.map(function(row) { 
					return row['event_price']; 
				});
			}

			
			var TESTER = document.getElementById('myDiv')
			  
			var trace1 = {
			  type: "scatter",
			  mode: "lines",
			  name: 'AAPL High',	  
			  //x: unpack(rows, 'event_time'),
			  //y: unpack(rows, 'event_price'),
			  x: unpackX(rows),
			  y: unpackY(rows),

			  line: {color: '#17BECF'}
			}	

			var data = [trace1];
				  
			var layout = {
				title: 'Time Series with Rangeslider', 
				dragmode: 'lasso',
				height: 700,
				margin: {
					l: 50,	r: 50,	b: 100,	t: 0,	pad: 2	},					
				xaxis: {
					autorange: true, type: 'time'}, 
				yaxis: {
					autorange: true, type: 'linear'	}			  
			};

			Plotly.newPlot(TESTER, data, layout);

			
			TESTER.on('plotly_selected', function(eventData) {
				$scope.processSelection(eventData);
			});

			TESTER.on('plotly_deselect', function() {
			  console.log('deselect');  
			});

		};		


		$scope.updateLayout = function(){
			
			var update = {
				dragmode: 'lasso'
			};
			
			var TESTER = document.getElementById('myDiv')
			Plotly.relayout(TESTER, update)
		};
		
		$scope.processSelection = function(eventData){
			var x = [];
			var y = [];

			eventData.lassoPoints.x.forEach(function(e){
			  x.push(e);
			});
			eventData.lassoPoints.y.forEach(function(e){
			  y.push(e);
			});

			if(x.length != y.length)
			  alert('warning! los lengths de X e Y son distintos! ' + x.length + ' , ' + y.length); 
			
			var box = $scope.get_roundingBox(x,y);
			var selectedPoints = $scope.getSelectedPoints(box);

			var new_selected_interval = new Object();
			var selected_points_x = selectedPoints.map(function(p){
				return p.x;
			});
			var selected_points_y = selectedPoints.map(function(p){
				return p.y;
			});
			var min_x = $scope.getMin(selected_points_x);
			var max_x = $scope.getMax(selected_points_x);
			var min_y = $scope.getMin(selected_points_y);
			var max_y = $scope.getMax(selected_points_y);	
			
			new_selected_interval.text = '[' + min_x + ' - ' + max_x + ']';
			new_selected_interval.x_max = max_x;
			new_selected_interval.x_min = min_x;
			new_selected_interval.y_max = max_y;
			new_selected_interval.y_min = min_y;
			
			new_selected_interval.points = selectedPoints;
			
			$scope.selectedIntervals.push(new_selected_interval);
			
			$scope.$apply();

		};
		
		$scope.doGraph = function(){
			
			var param = new Object();
			param.table = $scope.tableAsset;
			param.maxDate = $scope.maxDate;
			param.maxTime = $scope.maxTime;
			param.minDate = $scope.minDate;
			param.minTime = $scope.minTime;
			
			Todos.getTrades(param)
				.success(function(rows) {
					$scope.render(rows);
				});
		};
		
		$scope.doSaveIntervals = function() {
		
			var obj = new Object();
			obj.table = $scope.tableAsset;
			obj.name = $scope.labelName;
			obj.outputName = $scope.outputName
			obj.maxDate = $scope.maxDate;
			obj.maxTime = $scope.maxTime;
			obj.minDate = $scope.minDate;
			obj.minTime = $scope.minTime;			
			obj.intervals = $scope.selectedIntervals;
			obj.requireAdvances = $scope.requireAdvances;
		
			Todos.sendIntervals(obj)
				.success(function(data) {
					
				});
			
		};
		
		$scope.doLoadIntervals = function(){
			
			Todos.getLabelById($scope.labelName)
				.success(function(data){
					data = data[0];
					$scope.tableAsset = data.table;
					$scope.outputName = data.outputName;
					$scope.maxDate = data.maxDate;
					$scope.maxTime = data.maxTime;
					$scope.minDate = data.minDate;
					$scope.minTime = data.minTime;
					$scope.selectedIntervals = data.intervals;
					$scope.requireAdvances = data.requireAdvances;
			
				});
		};
		
		$scope.doRemoveInterval = function(e){
			
			var index = $scope.selectedIntervals.indexOf(e);
			$scope.selectedIntervals.splice(index,1);
			
		};

		
	}]);