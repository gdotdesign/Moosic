window.addEvent "domready", ->
  player = new Moosic.Player()
  album = 'Jazz U'
  artist = 'Antony Raijekov'
  songs = [
    'Deep blue (2005)'
    'Moment of Green (2005)'
    'Go \'n\' Drop (2003)'
    'Drop of whisper (2005)'
    'Ambient-M (2003)'
    'Don-ki-Not (2003)'
    'EXIT 65 (2005)'
    'Chillout me (2004)'
    'Lightout (2003)'
    'Fidder (2004)'
    'While We Walk (2004)'
    'By the Coast (2004)'
  ]
  src = [
    '01 - Deep blue (2005)'
    '02 - Moment of Green (2005)'
    '03 - Go \'n\' Drop (2003)'
    '04 - Drop of whisper (2005)'
    '05 - Ambient-M (2003)'
    '06 - Don-ki-Not (2003)'
    '07 - EXIT 65 (2005)'
    '08 - Chillout me (2004)'
    '09 - Lightout (2003)'
    '10 - Fidder (2004)'
    '11 - While We Walk (2004)'
    '12 - By the Coast (2004)'
  ]
  songs.each (song,i) ->
    player.wrapper.add 
      title: song
      album: album
      artist: artist
      src: "/songs/"+src[i]+".mp3"
      cover: '/cover.jpg'

  $("player").grab player
Moosic = {}
Moosic.Wrapper = new Class
  # Implementing Events
  Implements: Events
  initialize: (options)-> 
    # This is simpler then implementing Options
    @options = Object.merge {
      repeat: false
      shuffle: false
    }, options
    # Create the audio element and test for support 
    if (tag = document.createElement('audio')).canPlayType
      if tag.canPlayType('audio/mpeg')
        @audio = tag
        # Set attibutes for preloading and buffering
        @audio.preload = 'preload'
        @audio.autobuffer = true
        # Add events to the tag [timeupdate,ended]
        @addEvents()
        # Set up intance variables
        @playing = null
        @playlist = []
        @repeat = @options.repeat
        @shuffle = @options.shuffle
        # Add the tag to the page
        document.body.grab @audio
    @
    
  addEvents: ->
    # Timeupdate is for updating played / duration and progress bar
    @audio.addEventListener "timeupdate", @update.bind @
    # Ended is for playing the next song when one finishes
    @audio.addEventListener "ended", @ended.bind @
  
  update: ->
    # Get the songs current position and fire the update event
    fraction = (time = @audio.currentTime) / (duration = @audio.duration)
    @fireEvent 'update', [fraction, time, duration]
    
  # When a song ends play the next one
  ended: ->
    @next()

  # Check if the supplied object has everything we need
  check: (obj) ->
    obj.src? and obj.title? and obj.album? and obj.artist?
  
  # Stops the current song and fires the idle event
  stop: ->
    if @playing?
      @audio.pause()
      @audio.src = null
      @playing.playing = false
      @playing = null
      @fireEvent 'idle'
  
  # Pause the current song and fire the idle event    
  pause: ->
    if @playing?
      @audio.pause()
      @playing.playing = false
      @fireEvent 'pause'
  
  # Play the next song
  next: ->
    if @playing?
      # if shuffle is on
      if @shuffle
        # play a random song from the playlist
        @play @playlist.getRandom()
        # if not check for the next one
      else if (a = @playlist[@playlist.indexOf(@playing)+1])?
        # if found play it
        @play a, true
        # if not check for repeat
      else if @repeat
        # if repeat is on play the first song
        @play @playlist[0]
      else
        # else stop
        @stop()
   
  # Play the previous song, same as Next just backwards.
  prev: ->
    if @playing?
      if @shuffle
        @play @playlist.getRandom()
      else if (a = @playlist[@playlist.indexOf(@playing)-1])?
        @play(a,true)
      else if @repeat
        @play @playlist.getLast()
      else
        @stop()
        
  # Moosic.Song or object or index in the playlist
  # use force to play a song if a song is currently playing
  play: (song,force = false) ->
    # If the plyer is paused resume playback
    if @playing? and not force
      if @audio.paused
        @audio.play()
        @playing.playing = true
        @fireEvent 'resume', song
        return null
    if song?
      # get song based on index
      if typeOf(song) is 'number'
        song = @playlist[song-1]
      if song?
        if @check(song)
          if @playlist.indexOf(song) is -1
            if @check song
              # add song if not in playlist
              @add song
    else
      # if nothing was provided play the first
      song = @playlist[0]
    if song?
      if @playing? 
        @playing.playing = false
      @playing = song
      @playing.playing = true
      @audio.src = @playing.src
      @audio.play()
      @fireEvent 'play', [song,@playlist.indexOf(song)]

  # set an value
  set: (key,value) ->
    switch key 
      when "repeat"
        @repeat = value
      when "shuffle"
        @shuffle = value
        
  # get an value    
  get: (key,value) ->
    switch key 
      when "repeat"
        @repeat
      when "shuffle"
        @shuffle
  
  # empty the playlist      
  empty: (obj) ->
    @stop()
    @playlist.empty()
    @playlist = []  
    @fireEvent 'empty'
  
  # add a song to the playlist  
  add: (obj) ->
    if @check obj
      @playlist.push (song = new Moosic.Song(obj))
      @fireEvent 'added', [song, @playlist.length]
  
  # remove a song from the playlist      
  remove: (obj) ->
    if @check(obj) and (index = @playlist.indexOf(obj)) isnt -1
      @playlist.erase obj
      @fireEvent 'removed', [song, index]


Moosic.Player = new Class
  initialize: ->
    # create the base element
    @base = new Element 'div.player.idle'
    
    # cover and current song details
    info = new Element 'div.info'
    @cover = new Element 'div.cover'
    @details = new Element 'div.details'
    @title = new Element 'div.title'
    @album = new Element 'div.album'
    @artist = new Element 'div.artist'
    
    #controls
    controls = new Element 'div.controls'
    @play = new Element 'div.play'
    @prev = new Element 'div.prev'
    @next = new Element 'div.next'
    @repeat = new Element 'div.repeat'
    @empty = new Element 'div.empty'
    @shuffle = new Element 'div.shuffle'
    
    #progress bar
    @progress = new Element 'div.progress'
    @pbar = new Element 'div.bar'
    @pbarbg = new Element 'div.barbg'
    @progress.adopt @pbarbg, @pbar
    
    #volume bar
    @volume = new Element 'div.volume'
    @vbar = new Element 'div.bar'
    @vbarbg = new Element 'div.barbg'
    @volume.adopt @vbarbg, @vbar
    
    #playlist
    @playlist = new Element 'table'
    pls = new Element 'div.playlist'
    pls.grab @playlist
    
    # img and over for cover
    @cover.adopt (@img=new Element('div.img')), new Element('div.over')

    # get the tween for chaining    
    @imgTween = @img.get 'tween'
    
    # put every element together
    info.adopt @cover, @details, pls
    @details.adopt @title, @album, @artist
    controls.adopt @prev, @play, @next, @progress, @volume, @repeat, @shuffle, @empty
    @base.adopt info, controls

    # create the wrapper    
    @wrapper = new Moosic.Wrapper()
    
    # update the progress bar
    @wrapper.addEvent 'update', (fac,duration,currentTime) =>
      new_width = @pbarbg.getSize().x*fac
      @pbar.setStyle 'width', new_width
     
    # play 
    @wrapper.addEvent 'play', (song,index) =>
      @title.set 'text', song.title
      @album.set 'text', song.album
      @artist.set 'text', song.artist
      (children = @playlist.getChildren()).removeClass 'playing'
      children[index].addClass 'playing'
      @play.addClass 'playing'
      @play.addClass 'active'
      @base.removeClass 'idle'
      # cover change 
      @imgTween.start('opacity',1,0).chain =>
        @img.setStyle('background-image',"url('#{song.cover}')")
        @img.fade('in')
    
    # idle
    @wrapper.addEvent 'idle', =>
      $$(@title,@album,@artist).set 'text', ''
      @play.removeClass 'playing'
      @play.removeClass 'active'
      @base.addClass 'idle'
      @pbar.setStyle 'width',0
      @img.setStyle('background-image','none')
     
    # pause 
    @wrapper.addEvent 'pause', =>
      @play.removeClass 'playing'
      @play.removeClass 'active'
      @base.addClass 'idle'
    
    # resume
    @wrapper.addEvent 'resume', =>
      @play.addClass 'playing'
      @play.addClass 'active'
      @base.removeClass 'idle'
     
    # added and removed  
    @wrapper.addEvent 'added', (song, index) =>
      @drawPlaylist()
    @wrapper.addEvent 'removed', (song, index) =>
      @drawPlaylist()
    
    #volume change
    @volume.addEvent "click", (event) =>
      # get the offset
      clickoffset = event.client.x - @vbar.getPosition().x
      size = @vbarbg.getSize().x
      # calculate percentage
      percent = clickoffset/size
      # set new width and new volume
      newWidth = if percent < 0 then 0 else if percent > 1 then size else size*percent
      @vbar.setStyle 'width', newWidth-1
      @wrapper.audio.volume= if percent < 0 then 0 else if percent > 1 then 1 else percent
    
    #progress change
    @progress.addEvent "click", (event) =>
      if @wrapper.playing?
        dur = @wrapper.audio.duration
        # calculate percentage
        percent = (event.client.x - @pbar.getPosition().x) / (@pbarbg.getSize().x)
        duration_seek = percent*dur;
        @wrapper.audio.currentTime = duration_seek
     
    # click to play the song
    @playlist.addEvent 'click:relay(tr)', (e,el) =>
      @wrapper.play @playlist.getChildren().indexOf(el)+1, true
    
    # play button  
    @play.addEvent 'click', =>
      if @wrapper.playing
        if @wrapper.playing.playing
          @wrapper.pause()
        else
          @wrapper.play()
      else
        @wrapper.play()
    
    # next and prev buttons
    @next.addEvent 'click', =>
      @wrapper.next()
    @prev.addEvent 'click', =>
      @wrapper.prev()
    
    # empty button   
    @empty.addEvent 'click', =>    
      @wrapper.empty()
      @drawPlaylist()
    
    # shuffle and repeat button 
    @shuffle.addEvent 'click', =>
      @wrapper.set 'shuffle', !@wrapper.get('shuffle')
      if @wrapper.get('shuffle')
        @shuffle.addClass 'active' 
      else
        @shuffle.removeClass 'active' 
    @repeat.addEvent 'click', =>
      @wrapper.set 'repeat', !@wrapper.get('repeat')
      if @wrapper.get('repeat')
        @repeat.addClass 'active' 
      else
        @repeat.removeClass 'active' 
    @
    
  #draw the playlist
  drawPlaylist: ->
    @playlist.empty()
    @wrapper.playlist.each (song,i) =>
      tr = new Element 'tr'  
      tr.grab new Element('td.track',{text:if i+1 < 10 then "0"+(i+1) else i+1})
      tr.grab new Element('td.title',{text:song.title})
      @playlist.grab tr
      
  toElement: ->
    @base
    
Moosic.Song = new Class
  initialize: (obj) ->
    @playing = false
    @title = obj.title
    @cover = obj.cover
    @src = obj.src
    @album = obj.album
    @artist = obj.artist
