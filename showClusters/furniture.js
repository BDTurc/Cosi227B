angular.module("furnitureCluster",['angularModalService','ui.router','ui.bootstrap'])
.controller('modalController',ModelController)
.controller('clusterCtrl', ClusterCtrl)
.controller('roomCtrl', RoomCtrl)
.config(function($stateProvider, $urlRouterProvider) {

	$urlRouterProvider.otherwise("/explore");

	$stateProvider
	.state('explore', {
		url: '/explore',
		templateUrl: 'partials/explore.html',
		controller: 'clusterCtrl'
	})
	.state('room', {
		url: '/room',
		templateUrl: 'partials/room.html',
		controller: 'roomCtrl'
	})
})
.service('RoomService', function() {
	var Curf = "";
	var sofa,loveseat,storage,footstool = 0;

	var setFurniture = function(image) {
		Curf = image;
	};

	var getFurniture = function(){
		return Curf;
	};

	var setFurnCount = function (sfct,lsct,stct,fsct) {
		sofa = sfct;
		loveseat = lsct;
		storage = stct;
		footstool = fsct;
	}

	var clearFurniture = function(){
		Curf = "";
	};

	var getConfig = function(){
		var config = { 'room': {
			'url': Curf,
			'sofa': sofa,
			'loveseat': loveseat,
			'footstool': footstool,
			'storage': storage,
		}	}

		return config
	}

	return {
		setFurniture: setFurniture,
		getFurniture: getFurniture,
		setFurnCount: setFurnCount,
		clearFurniture: clearFurniture,
		getConfig: getConfig
	};
})
.factory('roomClusterApi', roomClusterApi)
.constant('roomClusterUrl', 'http://localhost:4567');

function roomClusterApi($http, roomClusterUrl) {

	var url = roomClusterUrl + '/room';

	return {
		buildRoom: function (config) {
			return $http.post(url,config)
		},
		getRoom: function () {
			return $http.get(url)
		}
	}
}

function ModelController ($scope, $timeout, $element, close, RoomService) {

	$scope.showing = "";
	$scope.sofa = 0;
	$scope.loveseat = 0;
	$scope.storage = 0;
	$scope.footstool = 0;

	$scope.showing = RoomService.getFurniture()

	$scope.close = function(result) {
		if (result=="Yes") {
			RoomService.setFurnCount($scope.sofa,$scope.loveseat,$scope.storage,$scope.footstool);
			$scope.prentending = true;
			timer = $timeout(function () {
				$scope.prentending = false;
				$element.modal('hide');
			}, 600);
		}
		timer = $timeout(function () {
			close(result, 0); // close, but give 600ms for bootstrap to animate
		}, 600);
	};
};

function RoomCtrl($http,$scope,$timeout,roomClusterApi,RoomService) {

	var config = RoomService.getConfig();
	$scope.room = null;
		roomClusterApi.buildRoom(config).success(function() {}).error(function() {});
			timer = $timeout(function () {
				roomClusterApi.getRoom().success(function (data){
					// var tmp = JSON.parse(data);
					$scope.room = data["room"];
					$scope.sofa = data["sofa"];
					$scope.loveseat = data["loveseat"];
					$scope.storage = data["storage"];
					$scope.footstool = data["footstool"];
				}
			)}, 400);
	}

	function ClusterCtrl($http,$scope,$state,ModalService,RoomService) {

		var shuffle = function(array) {
			var m = array.length, t, i;
			// While there remain elements to shuffle
			while (m) {
				// Pick a remaining element…
				i = Math.floor(Math.random() * m--);

				// And swap it with the current element.
				t = array[m];
				array[m] = array[i];
				array[i] = t;
			}
			return array;
		}

		$scope.showing = "";

		$scope.configRoom = function(image) {

			RoomService.setFurniture(image)

			ModalService.showModal({
				templateUrl: 'modal.html',
				controller: "modalController"
			}).then(function(modal) {
				modal.element.modal();
				modal.close.then(function(result) {
					$scope.showing = "";
					if (result=="Yes") {
						$state.go("room");
					}
				});
			});
		};

		$scope.reset = function() {
			$scope.clusterNumber = -1
			$scope.currentCatagory = "all"
		}

		$scope.setClusterNumber = function(cluster) {
			$scope.clusterNumber = cluster
		}

		$scope.setCatagory = function(catagory) {
			$scope.currentCatagory = catagory
		}

		$scope.makeRoom = function(image) {}

		$scope.showOptions = function(image) {}

		$scope.setOpacity = function(image) {
			var cond1 = $scope.clusterNumber == -1 || $scope.images[image]==$scope.clusterNumber
			var cond2 = $scope.currentCatagory=="all" || $scope.currentCatagory == $scope.catagories[image]
			if (cond1 && cond2) {
				return {"opacity": 1, "border": "solid 2px black"}
			}
			else
			{
				return {opacity: 0.1}
			}
		}

		$http.get('clusters.json').success(function (data){
			$scope.images = shuffle(data)
		});

		$http.get('catagories.json').success(function (data){
			$scope.catagories = data
		});

		$scope.status = {
			isopen: false
		};

		$scope.showOptions = function(image) {
			$scope.showing = image
			RoomService.setFurniture(image);
		}

		$scope.reset()

	};
