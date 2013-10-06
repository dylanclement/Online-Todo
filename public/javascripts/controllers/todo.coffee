class window.TodoCtrl
  constructor: ($scope, $http) ->

    @scope = $scope
    @http = $http
    # populate data

    window.scope = @scope
    @loadTodos()
    @scope.sortMode = 'Priority'
    @scope.$watch 'sortMode', (sortMode) =>
      # this method might get called before the items are loaded
      if !@scope.todos then return
      console.log 'Sort Mode = ', sortMode
      @sortTodos(sortMode)


    @scope.add = (newTodo) =>
      @http.post('/todos', newTodo)
        .success (newTodo) =>
          # add the item to the list
          @scope.todos.push newTodo
          # @sortableEl.refresh()
        .error alert


    @scope.del = (todo) =>
      console.log 'Deleting todo', todo
      @http.delete("/todo/#{todo._id}")
        .success (todos) =>
          # remove the item from the list and update the priorities
          @scope.todos = @scope.todos.filter (item) -> item._id != todo._id
          @scope.todos.forEach (item) -> item.pos -= 1 if item.pos > todo.pos
        .error alert


    @scope.save = (todo) =>
      console.log 'Saving todo', todo
      @http.put("/todo/#{todo._id}", todo)
        .success (todo) =>
          @scope.todos.forEach (item) ->
            if item._id == todo._id
              item.editing = false
          console.log 'Successfully saved on back end', todo
        .error alert


    @scope.cancel = (todo) =>
      @http.get("/todo/#{todo._id}", todo)
        .success (oldTodo) =>
          @scope.todos.forEach (item) ->
            if item._id == oldTodo._id
              item.editing = false
              todo.description = oldTodo.description
              todo.due = oldTodo.due
              todo.done = oldTodo.done
        .error alert

    @scope.editItem = (todo) -> todo.editing = !todo.editing

    @scope.dragStart = (e, ui) -> ui.item.data 'start', ui.item.index()

    @scope.dragEnd = (e, ui) =>
      change =
        start: ui.item.data 'start'
        end: ui.item.index()

      # update the todos in @scope
      @scope.todos.splice change.end, 0, @scope.todos.splice(change.start, 1)[0]
      @scope.$apply()
      console.log 'Reodering', change

      # update the order in the back end
      @http.post('/todos/re-order', change)
        .success =>
          console.log "Dragged from #{change.start} to #{change.end}.", @scope.todos
        .error alert


    @sortableEl = $('.sortable').sortable
      start: @scope.dragStart
      update: @scope.dragEnd

    $('.sortable').disableSelection()

  ###################################################################
  # class methods
  ###################################################################
  loadTodos: ->
    @http.get('/todos')
      .success (todos) =>
        # TODO! Remove the window.scope debugging code
        window.todos = @scope.todos = todos
      .error alert

  sortTodos: (sortMode)->
    if sortMode then @sortMode = sortMode # set the sort mode if it is passed in

    if @sortMode == 'Priority'
      @scope.todos.sort (a, b) -> return a.pos - b.pos

    else if @sortMode == 'DueDate'
      @scope.todos.sort (a, b) ->
        return new Date(b.due ? '1970-01-01') - new Date(a.due ? '1970-01-01')
    console.log @scope.todos, @sortMode

