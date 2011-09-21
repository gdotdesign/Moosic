window.addEvent "domready", ->
  prettyPrint()
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
      src: 'http://dl.dropbox.com/u/157845/moosic/'+encodeURI(src[i])+".mp3"
      cover: '/cover.jpg'

  $("player").grab player
  mySmoothScroll = new Fx.SmoothScroll()
    
