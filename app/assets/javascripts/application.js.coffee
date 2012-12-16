# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
# 
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
# 
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
# 
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.

//= require jquery
//= require jquery_ujs
//= require h5bp
//= require circle_event_manager
//= require underscore
//= require backbone
//= require backbone/streamphish
//= require util

# global namespace for stuff
window.App = {}

$ ->
  App.router = new Streamphish.Routers.AppRouter
  App.player = new Streamphish.Models.Player
  App.player_view = new Streamphish.Views.Player(model: App.player)

  # Setup link hijacking to go through Backbone
  $(document).on 'click', '#main a:not([data-bypass])', (e) ->
    href = prop: $(this).prop("href"), attr: $(this).attr("href")
    root = "#{location.protocol}//#{location.host}"

    if href.prop and (href.prop.slice(0, root.length) == root)
      e.preventDefault()
      App.router.navigate href.attr, true

  Backbone.history.start()