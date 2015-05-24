(function() {
  var BDGenerator, Generator, HHGenerator, MainGenerator, SynthGenerator, activeAttrs, activeEl, activeOffset, applyStyle, cmos, dragActive, dragEnd, generatorContructor, initd3, mainGen, max, sc,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.inits[200] = {
    desc: "Audiogenerator",
    init: function() {
      document.getElementById("newBD").addEventListener("click", mainGen.addBD);
      document.getElementById("newHH").addEventListener("click", mainGen.addHH);
      document.getElementById("newSynth").addEventListener("click", mainGen.addSynth);
      return c.l(new HHGenerator(0));
    }
  };

  applyStyle = function(el) {
    var key, val, _ref, _results;
    _ref = el.attrs;
    _results = [];
    for (key in _ref) {
      val = _ref[key];
      _results.push(el.style[key] = val);
    }
    return _results;
  };

  max = {
    w: window.innerWidth,
    h: window.innerHeight
  };

  activeOffset = {
    x: 0,
    y: 0
  };

  activeEl = null;

  activeAttrs = {};

  dragActive = function(e) {
    var x, y;
    if (activeEl != null) {
      y = e.y - activeOffset.y;
      x = e.x - activeOffset.x;
      if (y > max.y) {
        y = max.y;
      }
      if (x > max.x) {
        x = max.x;
      }
      if (y < 0) {
        y = 0;
      }
      if (x < 0) {
        x = 0;
      }
      x = activeEl.posx = Math.round(x / activeEl.attrs.width);
      y = activeEl.posy = Math.round(y / activeEl.attrs.height);
      activeEl.infoEl.innerText = x + ":" + y;
      activeEl.style.left = activeEl.x = x * activeEl.attrs.width;
      return activeEl.style.top = activeEl.y = y * activeEl.attrs.height;
    }
  };

  dragEnd = function() {
    return activeEl = null;
  };

  document.addEventListener("mousemove", dragActive, false);

  document.addEventListener("touchmove", dragActive, false);

  document.addEventListener("mouseup", dragEnd, false);

  document.addEventListener("touchend", dragEnd, false);

  generatorContructor = function(pos) {
    var dragField, infoRow, minusPosEl, minusVolumeEl, plusPosEl, plusVolumeEl, posRow, volRow;
    if (this.init) {
      this.init();
    }
    this.pos = pos;
    this.el = document.createElement("div");
    this.el.attrs = this.attrs;
    this.el.x = this.el.y = this.el.posx = this.el.posy = 0;
    this.el.classList.add("instrument");
    dragField = document.createElement("div");
    dragField.addEventListener("mousedown", this.makeActive, false);
    dragField.addEventListener("touchstart", this.makeActive, false);
    dragField.classList.add("dragField");
    this.el.appendChild(dragField);
    infoRow = document.createElement("div");
    this.el.infoEl = document.createElement("span");
    this.el.infoEl.innerHTML = null;
    this.adderEl = document.createElement("button");
    this.adderEl.addEventListener("click", this.changeAdder, false);
    this.adderEl.innerHTML = this.adderOptions[this.adder];
    this.fxEl = document.createElement("button");
    this.fxEl.addEventListener("click", null, false);
    this.fxEl.innerHTML = "?";
    infoRow.appendChild(this.fxEl);
    infoRow.appendChild(this.el.infoEl);
    infoRow.appendChild(this.adderEl);
    this.el.appendChild(infoRow);
    volRow = document.createElement("div");
    this.volumeEl = document.createElement("span");
    plusVolumeEl = document.createElement("button");
    minusVolumeEl = document.createElement("button");
    plusVolumeEl.innerHTML = "+";
    minusVolumeEl.innerHTML = "-";
    this.volumeEl.innerText = this.volume;
    volRow.appendChild(minusVolumeEl);
    volRow.appendChild(this.volumeEl);
    volRow.appendChild(plusVolumeEl);
    plusVolumeEl.addEventListener("click", this.plusVolume, false);
    minusVolumeEl.addEventListener("click", this.minusVolume, false);
    this.el.appendChild(volRow);
    posRow = document.createElement("div");
    this.posInfoEl = document.createElement("span");
    plusPosEl = document.createElement("button");
    minusPosEl = document.createElement("button");
    this.posInfoEl.innerHTML = this.pos;
    plusPosEl.innerHTML = "+";
    minusPosEl.innerHTML = "-";
    plusPosEl.addEventListener("click", this.plusPos, false);
    minusPosEl.addEventListener("click", this.minusPos, false);
    posRow.appendChild(minusPosEl);
    posRow.appendChild(this.posInfoEl);
    posRow.appendChild(plusPosEl);
    this.el.appendChild(posRow);
    applyStyle(this.el);
    document.getElementById("container").appendChild(this.el);
    activeEl = this.el;
    activeOffset = {
      x: this.attrs.width / 2,
      y: this.attrs.height / 2
    };
    return this;
  };

  Generator = (function() {
    var _class;

    function Generator() {
      this.makeActive = __bind(this.makeActive, this);
      this.changePosition = __bind(this.changePosition, this);
      this.minusPos = __bind(this.minusPos, this);
      this.plusPos = __bind(this.plusPos, this);
      this.changeVolume = __bind(this.changeVolume, this);
      this.minusVolume = __bind(this.minusVolume, this);
      this.plusVolume = __bind(this.plusVolume, this);
      this.changeAdder = __bind(this.changeAdder, this);
      return _class.apply(this, arguments);
    }

    _class = generatorContructor;

    Generator.prototype.p = 0;

    Generator.prototype.attrs = {
      left: max.w / 2,
      top: max.h / 2,
      width: 48,
      height: 48,
      background: "grey"
    };

    Generator.prototype.volume = 7;

    Generator.prototype.adder = 0;

    Generator.prototype.adderOptions = ["|", "&", "^", "+", "-"];

    Generator.prototype.adders = [
      function(a, b) {
        return a | b;
      }, function(a, b) {
        return a & b;
      }, function(a, b) {
        return a ^ b;
      }, function(a, b) {
        return a + b;
      }, function(a, b) {
        return a - b;
      }
    ];

    Generator.prototype.changeAdder = function() {
      this.adder += 1;
      this.adder %= this.adderOptions.length;
      return this.adderEl.innerHTML = this.adderOptions[this.adder];
    };

    Generator.prototype.plusVolume = function(e) {
      this.volume++;
      return this.changeVolume();
    };

    Generator.prototype.minusVolume = function(e) {
      this.volume--;
      return this.changeVolume();
    };

    Generator.prototype.changeVolume = function() {
      this.volume = this.volume & 7;
      return this.volumeEl.innerText = this.volume;
    };

    Generator.prototype.plusPos = function(e) {
      this.pos++;
      return this.changePosition();
    };

    Generator.prototype.minusPos = function(e) {
      this.pos--;
      return this.changePosition();
    };

    Generator.prototype.changePosition = function() {
      var len;
      c.l(this.pos);
      len = mainGen.generators.length;
      if (this.pos > len) {
        this.pos = 0;
      }
      if (this.pos < 0) {
        this.pos = len;
      }
      c.l(this.pos);
      mainGen.resortGenerators();
      return this.posInfoEl.innerText = this.pos;
    };

    Generator.prototype.makeActive = function(e) {
      c.l("makeActive");
      activeEl = this.el;
      return activeOffset = {
        x: e.offsetX,
        y: e.offsetY
      };
    };

    Generator.prototype.applyRest = function(sampleOld, sample) {
      var s;
      s = (s & 255) >> (7 - this.volume);
      return this.adders[this.adder](sampleOld, sample);
    };

    return Generator;

  })();

  BDGenerator = (function(_super) {
    __extends(BDGenerator, _super);

    function BDGenerator() {
      this.gen = __bind(this.gen, this);
      return BDGenerator.__super__.constructor.apply(this, arguments);
    }

    BDGenerator.prototype.init = function() {
      return this.attrs.background = "#f48";
    };

    BDGenerator.prototype.gen = function(so) {
      var s;
      s = (4 * (this.el.x * this.el.x + 1)) / (this.p % ((255 << 13) >> this.el.posy));
      this.applyRest(so, s);
      return this.p += 1;
    };

    return BDGenerator;

  })(Generator);

  HHGenerator = (function(_super) {
    __extends(HHGenerator, _super);

    function HHGenerator() {
      this.gen = __bind(this.gen, this);
      return HHGenerator.__super__.constructor.apply(this, arguments);
    }

    HHGenerator.prototype.init = function() {
      return this.attrs.background = "#4f8";
    };

    HHGenerator.prototype.gen = function(so) {
      var s;
      s = (1 * (this.el.x * this.el.x + 1)) / (Math.random() * (this.p % ((255 << 13) >> this.el.posy)));
      this.applyRest(so, s);
      return this.p += 1;
    };

    return HHGenerator;

  })(Generator);

  SynthGenerator = (function(_super) {
    __extends(SynthGenerator, _super);

    function SynthGenerator() {
      this.gen = __bind(this.gen, this);
      return SynthGenerator.__super__.constructor.apply(this, arguments);
    }

    SynthGenerator.prototype.init = function() {
      return this.attrs.background = "#84f";
    };

    SynthGenerator.prototype.gen = function(so) {
      var s, t;
      t = this.p;
      s = (Math.cos(t + (t & (255 - this.el.posx)))) * 127;
      this.applyRest(so, s);
      return this.p += ((this.el.posx + 1) * 55) / 44100;
    };

    return SynthGenerator;

  })(Generator);

  MainGenerator = (function() {
    function MainGenerator() {
      this.gen = __bind(this.gen, this);
      this.addSynth = __bind(this.addSynth, this);
      this.addHH = __bind(this.addHH, this);
      this.addBD = __bind(this.addBD, this);
    }

    MainGenerator.prototype.generators = [];

    MainGenerator.prototype.resortGenerators = function() {
      var newGenerator;
      newGenerator = [];
      return this.generators.forEach((function(_this) {
        return function(gen) {
          newGenerator[gen.pos] = gen;
          return gen.el.posInfoEl = gen.pos;
        };
      })(this));
    };

    MainGenerator.prototype.addBD = function() {
      return this.generators.push(new BDGenerator(this.generators.length));
    };

    MainGenerator.prototype.addHH = function() {
      return this.generators.push(new HHGenerator(this.generators.length));
    };

    MainGenerator.prototype.addSynth = function() {
      return this.generators.push(new SynthGenerator(this.generators.length));
    };

    MainGenerator.prototype.gen = function(e) {
      var i, out, s, _results;
      out = e.buffers;
      i = 0;
      s = 0;
      _results = [];
      while (i < e.bufferSize) {
        this.generators.forEach(function(gen, i) {
          return s = gen.gen(s);
        });
        s = 1 - ((s & 255) / 127);
        s /= 3;
        out[0][i] = out[1][i] = s;
        if (s > 1 || s < -1) {
          throw new Error("fatal sample is at value " + s);
        }
        _results.push(i++);
      }
      return _results;
    };

    return MainGenerator;

  })();

  mainGen = new MainGenerator();

  window.inits[100] = {
    desc: "imprtant stuff10",
    init: function() {}
  };

  cmos = {
    "divider": {
      inputs: ["clock", "clear"],
      outputs: [],
      states: {
        clock: 0,
        data: 0
      },
      gen: function() {
        return null;
      }
    }
  };

  sc = initd3 = function() {
    var force, height, linkArc, links, nodes, path, rect, svg, text, tick, transform, width;
    c.l("initd3");
    links = [
      {
        source: "Microsoft",
        target: "Amazon",
        type: "licensing"
      }, {
        source: "Amazon",
        target: "Samsung",
        type: "licensing"
      }, {
        source: "Samsung",
        target: "Motorola",
        type: "suit"
      }, {
        source: "Motorola",
        target: "Apple",
        type: "suit"
      }, {
        source: "Apple",
        target: "HTC",
        type: "resolved"
      }, {
        source: "HTC",
        target: "Apple",
        type: "suit"
      }, {
        source: "Kodak",
        target: "Apple",
        type: "suit"
      }
    ];
    nodes = {};
    tick = function() {
      path.attr('d', linkArc);
      rect.attr('transform', transform);
      return text.attr('transform', transform);
    };
    linkArc = function(d) {
      var dr, dx, dy;
      dx = d.target.x - d.source.x;
      dy = d.target.y - d.source.y;
      dr = Math.sqrt(dx * dx + dy * dy);
      return 'M' + d.source.x + ',' + d.source.y + 'A' + dr + ',' + dr + ' 0 0,1 ' + d.target.x + ',' + d.target.y;
    };
    transform = function(d) {
      return 'translate(' + d.x + ',' + d.y + ')';
    };
    links.forEach(function(link) {
      link.source = nodes[link.source] || (nodes[link.source] = {
        name: link.source
      });
      return link.target = nodes[link.target] || (nodes[link.target] = {
        name: link.target
      });
    });
    width = 960;
    height = 500;
    force = d3.layout.force().nodes(d3.values(nodes)).links(links).size([width, height]).linkDistance(160).charge(-30).on('tick', tick).start();
    svg = d3.select('body').append('svg').attr('width', width).attr('height', height);
    path = svg.append('g').selectAll('path').data(force.links()).enter().append('path').attr('class', function(d) {
      return 'link ' + d.type;
    }).attr('marker-end', function(d) {
      return 'url(#' + d.type + ')';
    });
    rect = svg.append('g').selectAll('rect').data(force.nodes()).enter().append('rect').attr('stroke-width', 1).attr('stroke', "#f00").attr('fill', "#aaa").attr('width', 64).attr('height', 64).call(force.drag).on("click", function() {
      return c.l("sad");
    });
    return text = svg.append('g').selectAll('text').data(force.nodes()).enter().append('text').attr('x', 8).attr('y', '.31em').text(function(d) {
      return d.name;
    });
  };

  window.onload = function() {
    return window.inits.forEach(function(init, i) {
      if (init.desc) {
        c.l(init.desc);
      }
      return init.init();
    });
  };

}).call(this);

//# sourceMappingURL=main.js.map
