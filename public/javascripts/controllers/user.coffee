class window.UserCtrl
  constructor: ($scope, $http, $location) ->

    @scope = $scope
    @http = $http
    @location = $location
    # populate data

    window.scope = @scope

    @scope.login = (user) =>
      @http.post("/auth/login", user)
        .success (msg) =>
          console.log 'Successfully logged in'
          window.location = '/'
        .error alert


    @scope.register = (user) =>
      @http.post("/auth/register", user)
        .success =>
          console.log 'Successfully registered user'
          window.location = '/'
        .error alert
