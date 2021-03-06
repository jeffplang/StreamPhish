class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs li': 'songClick'
    'click a.mic': 'showSourceInfo'

  initialize: (opts) ->
    super opts
    if opts.autoloadTrack
      trackPos = @_parsePosition(opts.trackPosition)
      @model.once 'change:tracks', (model) ->
        App.player.load model.get('tracks').where(slug: opts.autoloadTrack)[0], trackPos, opts.autoPlay

    App.player.on 'change:currentTrack', @updateUrl, @

  songClick: (e) ->
    e.preventDefault() # For clicks on <a>s within the <li>
    songId = $(e.target).closest('li').data 'id'
    song    = @model.get('tracks').get(songId)

    @updateUrl(song) # For when you come back to a show view and click the currently playing song
    App.player.play song

  updateUrl: (obj) ->
    if (obj instanceof Streamphish.Models.Player)
      track = obj.get('currentTrack')
    else
      track = obj

    url = "/shows/#{@model.get('show_date')}/#{track.get('slug')}"
    # We want to prevent the URL from being changed if we're calling this method
    # from the playing of an auto-loaded track
    if "/#{Backbone.history.fragment}" == url
      track.unset 'initialPosition'
      return 
    App.router.navigate url, replace: true

  showSourceInfo: (e) ->
    # Used to prevent href='#' from being routed...kinda shitty
    e.stopImmediatePropagation()
    e.preventDefault()
    $si = $('header .sourceInfo')
    $arrowStyle = this.$el.find('style:first')

    if $si.hasClass('invisible')
      cssLeft = -$si.width() / 2 + 4
      $si.css 'left', cssLeft

      shiftLeftDist = Math.ceil($si.outerWidth() + $si.offset().left) - window.innerWidth + 6
      styleStr = 'header div.sourceInfo:after { margin-left: Xpx; }'

      if shiftLeftDist > 0
        $si.css('left', cssLeft - shiftLeftDist)
        $arrowStyle.text styleStr.replace('X', -15 + shiftLeftDist)
      else
        $arrowStyle.text styleStr.replace('X', -15)


    $si.toggleClass('invisible')

  _parsePosition: (posStr) ->
    # Valid position strings:
    #   1m
    #   1m30s
    #   1m30000ms
    #   90s
    #   90000ms
    return 0 if !posStr? || posStr == ''
    pieces = posStr.match /((\d+)m(?!s))?((\d+)(s|ms))?/
    pos    = 0
    if pieces[5] # seconds or milliseconds piece
      if pieces[5] == 's'
        pos += parseInt(pieces[4], 10) * 1000
      else if pieces[5] == 'ms'
        pos += parseInt(pieces[4], 10)
    if pieces[2]
      pos += parseInt(pieces[2], 10) * 60000

    pos

  pageTitle: ->
    "#{SP.Helpers.dateString(@model.get('show_date'), '%m/%d/%Y')} #{@model.get('location')}"

  remove: ->
    App.player.off 'change:currentTrack', null, @
    super

  render: ->
    super
    window.scrollTo 0, 0
