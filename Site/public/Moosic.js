var Moosic;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
Moosic = {};
Moosic.Wrapper = new Class({
  Implements: Events,
  initialize: function(options) {
    var tag;
    this.options = Object.merge({
      repeat: false,
      shuffle: false
    }, options);
    if ((tag = document.createElement('audio')).canPlayType) {
      if (tag.canPlayType('audio/mpeg')) {
        this.audio = tag;
        this.audio.preload = 'preload';
        this.audio.autobuffer = true;
        this.addEvents();
        this.playing = null;
        this.playlist = [];
        this.repeat = this.options.repeat;
        this.shuffle = this.options.shuffle;
        document.body.grab(this.audio);
      }
    }
    return this;
  },
  addEvents: function() {
    this.audio.addEventListener("timeupdate", this.update.bind(this));
    return this.audio.addEventListener("ended", this.ended.bind(this));
  },
  update: function() {
    var duration, fraction, time;
    fraction = (time = this.audio.currentTime) / (duration = this.audio.duration);
    return this.fireEvent('update', [fraction, time, duration]);
  },
  ended: function() {
    return this.next();
  },
  check: function(obj) {
    return (obj.src != null) && (obj.title != null) && (obj.album != null) && (obj.artist != null);
  },
  stop: function() {
    if (this.playing != null) {
      this.audio.pause();
      this.audio.src = null;
      this.playing.playing = false;
      this.playing = null;
      return this.fireEvent('idle');
    }
  },
  pause: function() {
    if (this.playing != null) {
      this.audio.pause();
      this.playing.playing = false;
      return this.fireEvent('pause');
    }
  },
  next: function() {
    var a;
    if (this.playing != null) {
      if (this.shuffle) {
        return this.play(this.playlist.getRandom());
      } else if ((a = this.playlist[this.playlist.indexOf(this.playing) + 1]) != null) {
        return this.play(a, true);
      } else if (this.repeat) {
        return this.play(this.playlist[0]);
      } else {
        return this.stop();
      }
    }
  },
  prev: function() {
    var a;
    if (this.playing != null) {
      if (this.shuffle) {
        return this.play(this.playlist.getRandom());
      } else if ((a = this.playlist[this.playlist.indexOf(this.playing) - 1]) != null) {
        return this.play(a, true);
      } else if (this.repeat) {
        return this.play(this.playlist.getLast());
      } else {
        return this.stop();
      }
    }
  },
  play: function(song, force) {
    if (force == null) {
      force = false;
    }
    if ((this.playing != null) && !force) {
      if (this.audio.paused) {
        this.audio.play();
        this.playing.playing = true;
        this.fireEvent('resume', song);
        return null;
      }
    }
    if (song != null) {
      if (typeOf(song) === 'number') {
        song = this.playlist[song - 1];
      }
      if (song != null) {
        if (this.check(song)) {
          if (this.playlist.indexOf(song) === -1) {
            if (this.check(song)) {
              this.add(song);
            }
          }
        }
      }
    } else {
      song = this.playlist[0];
    }
    if (song != null) {
      if (this.playing != null) {
        this.playing.playing = false;
      }
      this.playing = song;
      this.playing.playing = true;
      this.audio.src = this.playing.src;
      this.audio.play();
      return this.fireEvent('play', [song, this.playlist.indexOf(song)]);
    }
  },
  set: function(key, value) {
    switch (key) {
      case "repeat":
        return this.repeat = value;
      case "shuffle":
        return this.shuffle = value;
    }
  },
  get: function(key, value) {
    switch (key) {
      case "repeat":
        return this.repeat;
      case "shuffle":
        return this.shuffle;
    }
  },
  empty: function(obj) {
    this.stop();
    this.playlist.empty();
    this.playlist = [];
    return this.fireEvent('empty');
  },
  add: function(obj) {
    var song;
    if (this.check(obj)) {
      this.playlist.push((song = new Moosic.Song(obj)));
      return this.fireEvent('added', [song, this.playlist.length]);
    }
  },
  remove: function(obj) {
    var index;
    if (this.check(obj) && (index = this.playlist.indexOf(obj)) !== -1) {
      this.playlist.erase(obj);
      return this.fireEvent('removed', [song, index]);
    }
  }
});
Moosic.Player = new Class({
  initialize: function() {
    var controls, info, pls;
    this.base = new Element('div.player.idle');
    info = new Element('div.info');
    this.cover = new Element('div.cover');
    this.details = new Element('div.details');
    this.title = new Element('div.title');
    this.album = new Element('div.album');
    this.artist = new Element('div.artist');
    controls = new Element('div.controls');
    this.play = new Element('div.play');
    this.prev = new Element('div.prev');
    this.next = new Element('div.next');
    this.repeat = new Element('div.repeat');
    this.empty = new Element('div.empty');
    this.shuffle = new Element('div.shuffle');
    this.progress = new Element('div.progress');
    this.pbar = new Element('div.bar');
    this.pbarbg = new Element('div.barbg');
    this.progress.adopt(this.pbarbg, this.pbar);
    this.volume = new Element('div.volume');
    this.vbar = new Element('div.bar');
    this.vbarbg = new Element('div.barbg');
    this.volume.adopt(this.vbarbg, this.vbar);
    this.playlist = new Element('table');
    pls = new Element('div.playlist');
    pls.grab(this.playlist);
    this.cover.adopt((this.img = new Element('div.img')), new Element('div.over'));
    this.imgTween = this.img.get('tween');
    info.adopt(this.cover, this.details, pls);
    this.details.adopt(this.title, this.album, this.artist);
    controls.adopt(this.prev, this.play, this.next, this.progress, this.volume, this.repeat, this.shuffle, this.empty);
    this.base.adopt(info, controls);
    this.wrapper = new Moosic.Wrapper();
    this.wrapper.addEvent('update', __bind(function(fac, duration, currentTime) {
      var new_width;
      new_width = this.pbarbg.getSize().x * fac;
      return this.pbar.setStyle('width', new_width);
    }, this));
    this.wrapper.addEvent('play', __bind(function(song, index) {
      var children;
      this.title.set('text', song.title);
      this.album.set('text', song.album);
      this.artist.set('text', song.artist);
      (children = this.playlist.getChildren()).removeClass('playing');
      children[index].addClass('playing');
      this.play.addClass('playing');
      this.play.addClass('active');
      this.base.removeClass('idle');
      return this.imgTween.start('opacity', 1, 0).chain(__bind(function() {
        this.img.setStyle('background-image', "url('" + song.cover + "')");
        return this.img.fade('in');
      }, this));
    }, this));
    this.wrapper.addEvent('idle', __bind(function() {
      $$(this.title, this.album, this.artist).set('text', '');
      this.play.removeClass('playing');
      this.play.removeClass('active');
      this.base.addClass('idle');
      this.pbar.setStyle('width', 0);
      return this.img.setStyle('background-image', 'none');
    }, this));
    this.wrapper.addEvent('pause', __bind(function() {
      this.play.removeClass('playing');
      this.play.removeClass('active');
      return this.base.addClass('idle');
    }, this));
    this.wrapper.addEvent('resume', __bind(function() {
      this.play.addClass('playing');
      this.play.addClass('active');
      return this.base.removeClass('idle');
    }, this));
    this.wrapper.addEvent('added', __bind(function(song, index) {
      return this.drawPlaylist();
    }, this));
    this.wrapper.addEvent('removed', __bind(function(song, index) {
      return this.drawPlaylist();
    }, this));
    this.volume.addEvent("click", __bind(function(event) {
      var clickoffset, newWidth, percent, size;
      clickoffset = event.client.x - this.vbar.getPosition().x;
      size = this.vbarbg.getSize().x;
      percent = clickoffset / size;
      newWidth = percent < 0 ? 0 : percent > 1 ? size : size * percent;
      this.vbar.setStyle('width', newWidth - 1);
      return this.wrapper.audio.volume = percent < 0 ? 0 : percent > 1 ? 1 : percent;
    }, this));
    this.progress.addEvent("click", __bind(function(event) {
      var dur, duration_seek, percent;
      if (this.wrapper.playing != null) {
        dur = this.wrapper.audio.duration;
        percent = (event.client.x - this.pbar.getPosition().x) / (this.pbarbg.getSize().x);
        duration_seek = percent * dur;
        return this.wrapper.audio.currentTime = duration_seek;
      }
    }, this));
    this.playlist.addEvent('click:relay(tr)', __bind(function(e, el) {
      return this.wrapper.play(this.playlist.getChildren().indexOf(el) + 1, true);
    }, this));
    this.play.addEvent('click', __bind(function() {
      if (this.wrapper.playing) {
        if (this.wrapper.playing.playing) {
          return this.wrapper.pause();
        } else {
          return this.wrapper.play();
        }
      } else {
        return this.wrapper.play();
      }
    }, this));
    this.next.addEvent('click', __bind(function() {
      return this.wrapper.next();
    }, this));
    this.prev.addEvent('click', __bind(function() {
      return this.wrapper.prev();
    }, this));
    this.empty.addEvent('click', __bind(function() {
      this.wrapper.empty();
      return this.drawPlaylist();
    }, this));
    this.shuffle.addEvent('click', __bind(function() {
      this.wrapper.set('shuffle', !this.wrapper.get('shuffle'));
      if (this.wrapper.get('shuffle')) {
        return this.shuffle.addClass('active');
      } else {
        return this.shuffle.removeClass('active');
      }
    }, this));
    this.repeat.addEvent('click', __bind(function() {
      this.wrapper.set('repeat', !this.wrapper.get('repeat'));
      if (this.wrapper.get('repeat')) {
        return this.repeat.addClass('active');
      } else {
        return this.repeat.removeClass('active');
      }
    }, this));
    return this;
  },
  drawPlaylist: function() {
    this.playlist.empty();
    return this.wrapper.playlist.each(__bind(function(song, i) {
      var tr;
      tr = new Element('tr');
      tr.grab(new Element('td.track', {
        text: i + 1 < 10 ? "0" + (i + 1) : i + 1
      }));
      tr.grab(new Element('td.title', {
        text: song.title
      }));
      return this.playlist.grab(tr);
    }, this));
  },
  toElement: function() {
    return this.base;
  }
});
Moosic.Song = new Class({
  initialize: function(obj) {
    this.playing = false;
    this.title = obj.title;
    this.cover = obj.cover;
    this.src = obj.src;
    this.album = obj.album;
    return this.artist = obj.artist;
  }
});
