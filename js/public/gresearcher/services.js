angular.module('todoService', [])
	.factory('Todos', ['$http',function($http) {
		return {
			getTrades : function(param) {
				return $http.post('/get_trades_by_datetime_range',param);
			},
			sendIntervals : function(param) {
				return $http.post('/labels/intervals/', param);
			},
			getLabelById: function(param){
				return $http.get('/labels/' + param );
			},
		}
	}]);