class Streamphish.Models.Song extends Backbone.Model
  urlRoot: '/songs'

  # initialize: ->
  #   @on 'change:tracks', (model, tracks) ->
  #     @set 'tracks', 
  #       new Streamphish.Collections.Tracks(
  #         (new Streamphish.Models.Track(track) for track in tracks)), 
  #       silent: true

class Streamphish.Collections.Songs extends Backbone.Collection
  url: '/songs'
  model: Streamphish.Models.Song