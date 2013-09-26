class window.TodoCtrl
  constructor: ($scope, $http) ->
    $http.get('/todos')
      .success (todos) ->
        $scope.todos = todos
        console.log 'Todos = ', $scope.todos