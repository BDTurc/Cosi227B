angular.module("furnitureCluster",[]).controller('clusterCtrl', ClusterCtrl);


function ClusterCtrl($http,$scope) {
		
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


	$scope.reset = function() {
		$scope.clusterNumber = -1
		$scope.currentCatagory = "all"
	}

	$scope.setClusterNumber = function(cluster) {
		$scope.clusterNumber = cluster
	}

	$scope.setCatagory = function(catagory) {
		console.log(catagory)
		$scope.currentCatagory = catagory
		console.log($scope.currentCatagory)
	}

	$scope.setOpacity = function(image) {
		console.log($scope.currentCatagory)
		var cond1 = $scope.clusterNumber == -1 || $scope.images[image]==$scope.clusterNumber
		var cond2 = $scope.currentCatagory=="all" || $scope.currentCatagory == $scope.catagories[image]
		if (cond1 && cond2) {
			return {opacity: 1} }
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

	$scope.reset()

}