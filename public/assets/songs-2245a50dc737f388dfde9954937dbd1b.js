(function(){var t,e,n,r,i,o=function(t,e){return function(){return t.apply(e,arguments)}};r=function(){function n(n){var r,i=this;this.$song=n,this.title=this.$song.data("title"),this.show=this.$song.data("show"),this.$duration=this.$song.find("time.totalTime"),this.$currentTime=this.$song.find("time.currentTime"),this.songUri=this.$song.data("song-uri"),this.duration=this.$song.data("duration"),this.scrubber=new e(this),this.$markers=this.$song.find(".marker"),r=this,this.sound=soundManager.createSound({id:this.songUri,url:this.songUri,autoPlay:!1,whileloading:function(){var t;return r.durationLoaded=this.duration,t=Math.round(100*(this.duration/r.duration))+"%",r.scrubber.$loadingBar.width(t)},onload:function(t){return t?r.scrubber.$loadingBar.width("100%"):void 0},whileplaying:function(){return r.updateUIPosition(this.position)},onfinish:function(){return SP.SongM.playNext()}}),this.$song.data("song",this),this.$markers.each(function(e,n){var r;return r=$(n),r.data("marker",new t(i,r.data("position")))})}return n.prototype.togglePause=function(){return this.sound.togglePause(),this.$song.toggleClass("paused"),SP.SongM.toggleTitleAnimation()},n.prototype.play=function(){if(this.sound.paused)return this.togglePause(),void 0;if(1!==this.sound.playState)return this._setPageTitle(),this.$song.addClass("playing"),this.sound.play(),SP.SongM.toggleTitleAnimation()},n.prototype.stop=function(){return this.$song.removeClass("playing").removeClass("paused"),this.sound.stop(),SP.SongM.isTitleAnimating()?SP.SongM.toggleTitleAnimation():void 0},n.prototype.goToPosition=function(t){return t>this.durationLoaded?!1:(this.sound.setPosition(t),this.updateUIPosition(t),!0)},n.prototype.isPaused=function(){return this.sound.paused},n.prototype.updateCurrentTime=function(t){return this.$currentTime.text(SP.Util.msToMMSS(t))},n.prototype.updateUIPosition=function(t){return this.scrubber.$handle.hasClass("grabbed")||this.updateCurrentTime(t),this.scrubber.moveToPercent(t/this.duration)},n.prototype._setPageTitle=function(){var t;return t=document.title.indexOf(":: "),document.title=-1===t?this.title+" :: "+(this.show||document.title):this.title+" :: "+(this.show||document.title.slice(t+3,document.title.length))},n}(),i=function(){function t(){this._handleSongClick=o(this._handleSongClick,this),soundManager.setup({url:"/assets/",useHTML5Audio:!0,preferFlash:!1,debugMode:!1}),this.$songList=$(".songs"),this.$songList.on("click","li",this._handleSongClick),this.$songList.on("click","li a",function(t){return t.stopPropagation()})}return t.prototype._handleSongClick=function(t){var e;return e=$(t.currentTarget),e.hasClass("playing")?e.data("song").togglePause():this.playSong(e)},t.prototype.playSong=function(t){var e;return this.silence(),e=t.data("song"),null==e&&(e=new r(t)),e.play()},t.prototype.playNext=function(){var t;return t=this.$songList.children(".playing").next("li"),t.length?this.playSong(t):this.silence()},t.prototype.silence=function(){var t;return t=this.$songList.children(".playing"),t.length?t.data("song").stop():void 0},t.prototype.isTitleAnimating=function(){return null!=this._animating},t.prototype.toggleTitleAnimation=function(){var t=this;return this._title||(this._title=document.title),this._frames||(this._frames=["~","~",">"]),null!=this._animating?(clearInterval(this._titleAnimation),document.title=this._title,this._title=this._animating=null):(this._titleAnimation=setInterval(function(){return t._frames.unshift(t._frames.pop()),document.title=t._frames.join("")+" "+t._title},500),this._animating=!0)},t}(),e=function(){function t(t){this.song=t,this.$song=this.song.$song,this.$scrubber=this.$song.find(".scrubber"),this.$loadingBar=this.$song.find(".loadingProgress"),this.$handle=this.$scrubber.find(".handle"),this.$scrubber.data("scrubber",this)}return t.distance=251,t.prototype.moveToPercent=function(e){return this.$handle.hasClass("grabbed")?void 0:this.$handle.css("left",Math.round(t.distance*e))},t}(),n=function(){function t(){this._mouseUpHandler=o(this._mouseUpHandler,this),this._mouseMoveHandler=o(this._mouseMoveHandler,this),this._mouseDownHandler=o(this._mouseDownHandler,this),$(".songs").on("mousedown touchstart",".scrubber .handle",this._mouseDownHandler),$(".songs").on("click",".scrubber .handle",function(){return!1})}return t.prototype._mouseDownHandler=function(t){return t.originalEvent.preventDefault(),this.scrubber=$(t.currentTarget).closest(".scrubber").data("scrubber"),this.handleOffset=this.scrubber.$handle.width()/2,this.scrubberOffset=this.scrubber.$scrubber.offset().left,this.scrubber.$handle.addClass("grabbed"),this._toggleHandleHandlers()},t.prototype._mouseMoveHandler=function(t){var n;return n=SP.Util.clamp(t.pageX-this.scrubberOffset-this.handleOffset,0,t.data.loadingWidth),this.potentialSongPos=Math.round(this.scrubber.song.duration*(n/e.distance)),this.scrubber.song.updateCurrentTime(this.potentialSongPos),this.scrubber.$handle.css("left",n)},t.prototype._mouseUpHandler=function(){return this.scrubber.song.goToPosition(this.potentialSongPos),this.scrubber.$handle.removeClass("grabbed"),this.scrubber=null,this._toggleHandleHandlers()},t.prototype._toggleHandleHandlers=function(){var t;return t=$(document),null!=this.scrubber?t.on("mousemove touchmove",null,{loadingWidth:this.scrubber.$loadingBar.width()},this._mouseMoveHandler).on("mouseup touchend",this._mouseUpHandler):t.off("mouseup mousemove touchend touchmove")},t}(),t=function(){function t(t,e){this.song=t,this.position=e}return t.initMarkers=function(){return $(".marker a").on("click",function(t){var e;return t.stopPropagation(),e=$(t.currentTarget).parent().data("marker"),e.song.goToPosition(e.position),setTimeout(function(){return e.song.play()},300)})},t}(),$(function(){return SP.SongM=new i,SP.ScrbM=new n,t.initMarkers()})}).call(this);