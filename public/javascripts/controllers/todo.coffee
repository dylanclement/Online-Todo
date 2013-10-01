class window.TodoCtrl
  constructor: ($scope, $http) ->
    $http.get('/todos')
      .success (todos) ->
        $scope.todos = todos
      .error (err) -> alert err

    $scope.add = (newTodo) ->
      $http.post('/todos', newTodo)
        .success (newTodo) ->
          # add the item to the list
          $scope.todos.push newTodo
        .error (err) -> alert err

    $scope.del = (todo) ->
      console.log 'Deleting todo', todo
      $http.delete("/todo/#{todo._id}")
        .success ->
          # remove the item from the list
          $scope.todos = $scope.todos.filter (item) -> item._id != todo._id
        .error (err) -> alert err

    # toggle edit mode
    $scope.editItem = (todo) -> todo.editing = !todo.editing

    $scope.save = (todo) ->
      console.log 'Saving todo', todo
      $http.put("/todo/#{todo._id}", todo)
        .success (todo) ->
          $scope.todos.map (item) ->
            if item._id == todo._id
              item.editing = false
          console.log 'Successfully saved on back end', todo
        .error (err) -> alert err


