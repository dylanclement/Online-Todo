class window.TodoCtrl
  constructor: ($scope, $http) ->

    @scope = $scope
    @http = $http

    # TODO! Debug code, remove
    window.scope = @scope
    # populate data
    @loadTodos()
    @scope.sortMode = 'Priority'
    @scope.$watch 'sortMode', (sortMode) =>
      # this method might get called before the items are loaded
      if !@scope.todos then return
      console.log 'Sort Mode = ', sortMode
      @sortTodos sortMode

    @scope.setUser = (username, password, id) =>
      @user = {username, password, id}
      console.log 'User =', @user

    @scope.add = (newTodo) =>

      if !newTodo?.description then return console.log 'Empty description, not saving'
      # newTodo.user = @user
      console.log 'newTodo =', newTodo
      @http.post('/app/todos', newTodo)
        .success (newTodo) =>
          # add the item to the list
          @scope.todos.push newTodo
          # @sortableEl.refresh()
        .error alert

    @scope.cssClass = (todo) ->
      if todo.done then return 'done'
      if new Date(todo.due) <= new Date() then return 'overdue'

    @scope.del = (todo) =>
      console.log 'Deleting todo', todo
      @http.delete("/app/todo/#{todo._id}")
        .success (todos) =>
          # remove the item from the list and update the priorities
          @scope.todos = @scope.todos.filter (item) -> item._id != todo._id
          @scope.todos.forEach (item) -> item.pos -= 1 if item.pos > todo.pos
        .error alert


    @scope.save = (todo) =>
      console.log 'Saving todo', todo
      @http.put("/app/todo/#{todo._id}", todo)
        .success (todo) =>
          @scope.todos.forEach (item) ->
            if item._id == todo._id
              item.editing = false
          console.log 'Successfully saved on back end', todo
        .error alert


    @scope.cancel = (todo) =>
      @http.get("/app/todo/#{todo._id}", todo)
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
      @http.post('/app/todos/re-order', change)
        .success =>
          console.log "Dragged from #{change.start} to #{change.end}.", @scope.todos
        .error alert


    @sortableEl = $('.sortable')
    @sortableEl.sortable
      start: @scope.dragStart
      update: @scope.dragEnd

    $('.sortable').disableSelection()

  ###################################################################
  # class methods
  ###################################################################
  loadTodos: ->
    @http.get('/app/todos')
      .success (todos) =>
        # TODO! Remove the window.scope debugging code
        window.todos = @scope.todos = todos
      .error alert

  sortTodos: (sortMode)->
    if sortMode then @sortMode = sortMode # set the sort mode if it is passed in

    if @sortMode == 'Priority'
      @sortableEl.sortable "enable"
      @scope.todos.sort (a, b) -> return a.pos - b.pos

    else if @sortMode == 'DueDate'
      @sortableEl.sortable "disable"
      @scope.todos.sort (a, b) ->
        return new Date(b.due ? '1970-01-01') - new Date(a.due ? '1970-01-01')
    console.log @scope.todos, @sortMode

