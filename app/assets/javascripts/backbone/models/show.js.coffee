class Streamphish.Models.Show extends Backbone.Model
  urlRoot: '/shows'

  initialize: ->
    super
    # The 'tracks' attribute is just JSON data from the server at first..we want to convert it into a Backbone track collection
    @on 'change:tracks', (model, tracks) =>
      @set 'tracks', 
           new Streamphish.Collections.Tracks( (new Streamphish.Models.Track(track) for track in tracks) )
           silent: true
      @get('tracks').show = model
    # Strip out set info, set tracks as normally
    @on 'change:sets', (model, sets) ->
      _tracks = _.flatten( _.map(sets, (set) -> set.tracks) )
      _sets   = []
      _.reduce sets, ((beforeTrackIdx, set) -> 
        _sets.push( {title: set.title, beforeTrackIdx: beforeTrackIdx} )
        beforeTrackIdx + set.tracks.length), 0

      @set 'sets', _sets, silent: true
      @set 'tracks', _tracks


  year: =>
    @get('show_date').split('-')[0]

  toJSON: ->
    json = super
    json.year = @year()
    json

  fetch: (opts) ->
    _success = opts.success
    _.extend opts, 
      success: (model, resp, opts) =>
        _success(model, resp, opts)
        @fetched = true

    super opts

class Streamphish.Collections.Shows extends Backbone.Collection
  url: '/shows'
  model: Streamphish.Models.Show

  initialize: (models, opts) ->
    @year = opts.year if opts.year
    super models, opts

  toJSON: ->
    year: @year
    shows: super

  fetch: (opts = {}) ->
    if @year
      opts.data ?= {}
      opts.data.year = @year
    super opts