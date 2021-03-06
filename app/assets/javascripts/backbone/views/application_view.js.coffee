class SP.Views.ApplicationView extends Backbone.View
  tagName: 'div'
  id: 'currentView'

  initialize: ->
    this.$el = $('#currentView') if App.router.sequence == 0
    super

  bypassLink: (e) ->
    $(document).trigger e
    false

  render: ->
    # This hack is if this.model is a collection.  Underscore templates expect
    # data to come in an object (to be used in a with statement), or for the 
    # 'variable' option to be passed in during the compilation step.

    json = (@model || @collection).toJSON()
    if json instanceof Array
      json = {data: json} 

    @$el.html @template(json)
    @
