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
	var picks = [];

	var setFurniture = function(image) {
		Curf = image;
	};

	var setPicks = function(twoFurn) {
		picks = twoFurn;
	}

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
			'picks': picks,
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
		setPicks:	setPicks,
		setFurnCount: setFurnCount,
		clearFurniture: clearFurniture,
		getConfig: getConfig
	};
})
.factory('roomClusterApi', roomClusterApi)
.constant('roomClusterUrl', 'http://localhost:4567')
.constant('ikeaLink', 'http://www.ikea.com/us/en/')
.constant('centersFile','centers.json');
.constant('clustersFile','clusters.json')

// ============================================================================================================================

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

function ModelController ($scope, $timeout, $element, $http, close, RoomService, centersFile) {

	$scope.showing = "none";
	$scope.picked = [];
	$scope.sofa = 0;
	$scope.loveseat = 0;
	$scope.storage = 0;
	$scope.footstool = 0;
	$scope.step = 2;

	$scope.showing = RoomService.getFurniture()

	if ($scope.showing == "none") {
		$scope.step = 1;
		$http.get(centersFile).success(function (data){
			$scope.centers = data;
		});
	}

	$scope.select = function(image) {
		var idx = $scope.picked.indexOf(image);
		if (idx == -1) {
			if ($scope.picked.length<2) {
				$scope.picked.push(image)
			}
		} else {
			$scope.picked.splice(idx, 1);
		}
	}

	$scope.next = function() {
		$scope.step = 2;
	}

	$scope.selected = function(image) {
		if ($scope.picked.indexOf(image) != -1) {
			return {"border": "solid 2px black"}
		} else {
			return { }
		}
	}

	$scope.close = function(result) {
		if (result=="Yes") {
			RoomService.setFurnCount($scope.sofa,$scope.loveseat,$scope.storage,$scope.footstool);
			RoomService.setPicks($scope.picked);
			$scope.prentending = true;
			timer = $timeout(function () {
				$scope.prentending = false;
				$element.modal('hide');
			}, 500);
		}
		timer = $timeout(function () {
			close(result, 0); // close, but give 600ms for bootstrap to animate
		}, 600);
		$scope.showing = "none";
	};
};

function RoomCtrl($http,$scope,$timeout,roomClusterApi,RoomService) {

	$scope.waiting = false;
	var config = RoomService.getConfig();
	$scope.room = null;
		roomClusterApi.buildRoom(config).success(function() {}).error(function() {});
			$scope.waiting = true;
			timer = $timeout(function () {
				roomClusterApi.getRoom().success(function (data){
					$scope.room = data["room"];
					$scope.sofa = data["sofa"];
					$scope.loveseat = data["loveseat"];
					$scope.storage = data["storage"];
					$scope.footstool = data["footstool"];
				}
			)}, 600);
			$scope.waiting = false;
			RoomService.setPicks([]);
	}

	function ClusterCtrl($http,$scope,$state,ModalService,RoomService,ikeaLink,clustersFile) {

		$scope.showing = "";
		$scope.ikeaLink = ikeaLink;

		$scope.configRoom = function(image) {
			$state.go("explore");
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

		$http.get(clustersFile).success(function (data){
			$scope.images = data
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
