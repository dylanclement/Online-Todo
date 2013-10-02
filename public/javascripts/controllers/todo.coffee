class window.TodoCtrl
  constructor: ($scope, $http) ->

    # populate data
    $http.get('/todos')
      .success (todos) ->
        $scope.todos = todos
      .error alert



    $scope.add = (newTodo) =>
      $http.post('/todos', newTodo)
        .success (newTodo) =>
          # add the item to the list
          $scope.todos.push newTodo
          # @sortableEl.refresh()
        .error alert


    $scope.del = (todo) ->
      console.log 'Deleting todo', todo
      $http.delete("/todo/#{todo._id}")
        .success ->
          # remove the item from the list
          $scope.todos = $scope.todos.filter (item) -> item._id != todo._id
        .error alert


    # toggle edit mode
    $scope.editItem = (todo) ->
      todo.editing = !todo.editing


    $scope.save = (todo) ->
      console.log 'Saving todo', todo
      $http.put("/todo/#{todo._id}", todo)
        .success (todo) ->
          $scope.todos.map (item) ->
            if item._id == todo._id
              item.editing = false
          console.log 'Successfully saved on back end', todo
        .error alert


    $scope.dragStart = (e, ui) ->   ui.item.data 'start', ui.item.index()

    $scope.dragEnd = (e, ui) ->
      change =
        start: ui.item.data 'start'
        end: ui.item.index()

      # update the todos in $scope
      $scope.todos.splice change.end, 0, $scope.todos.splice(change.start, 1)[0]
      $scope.$apply()
      console.log 'Reodering', change

      # update the order in the back end
      $http.post('/todos/re-order', change)
        .success ->
          console.log "Dragged from #{change.start} to #{change.end}.", $scope.todos
        .error alert


    @sortableEl = $('.sortable').sortable
      start: $scope.dragStart
      update: $scope.dragEnd

    $('.sortable').disableSelection()
