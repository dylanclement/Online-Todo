class window.TodoCtrl
  constructor: ($scope) ->
    $scope.todos = [
      {text:'learn angular', done:true}
      {text:'build an angular app', done:false}
    ]