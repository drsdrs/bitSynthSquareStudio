(function() {
  var BUFFERLENGTH, CHANNELS, MainGenerator, SAMPLERATE, addNode, dly, draw, frequency, gen1, initD3Gen, initModels, initWebAudio, mainGenerator, manualRun, synth,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  mainGenerator = null;

  dly = null;

  gen1 = null;

  window.inits[350] = {
    desc: "Audiogenerator",
    init: function() {
      var addGenerator;
      initModels();
      addGenerator = function(e) {
        var newPart;
        if (e.target.id != null) {
          c.l("add", e.target.id.split("new"));
          newPart = new synth.partClasses[e.target.id.split("new")[1]];
          synth.parts.push(newPart);
          addNode(newPart);
          mainGenerator.findGenerators();
          return draw();
        }
      };
      document.getElementById("newGenerator").addEventListener("click", addGenerator);
      document.getElementById("newMixer").addEventListener("click", addGenerator);
      document.getElementById("newDelay").addEventListener("click", addGenerator);
      return (function() {
        var gen2, gen3, gen4, mix1, mix2, mstr;
        gen1 = new synth.partClasses.Generator;
        gen2 = new synth.partClasses.Generator;
        gen3 = new synth.partClasses.Generator;
        gen4 = new synth.partClasses.Generator;
        mix1 = new synth.partClasses.Mixer;
        mix2 = new synth.partClasses.Mixer;
        dly = new synth.partClasses.Delay;
        mstr = new synth.partClasses.Master;
        gen1.freq = 220;
        gen2.freq = 110;
        gen3.freq = 55;
        gen1.outputs.push(dly);
        dly.addInput(gen1);
        synth.parts.push(gen1);
        synth.parts.push(gen2);
        synth.parts.push(gen3);
        synth.parts.push(gen4);
        synth.parts.push(mix1);
        synth.parts.push(dly);
        synth.parts.push(mix2);
        synth.parts.push(mstr);
        window.mainGen = mainGenerator = new MainGenerator;
        return Pico.play(mainGenerator.gen);
      })();
    }
  };

  document.body.addEventListener("mousemove", function(e) {
    var maxX, ratio, x, y;
    maxX = window.innerWidth;
    x = e.clientX;
    y = e.clientY;
    ratio = x / maxX;
    return gen1.freq = x * 3;
  });

  MainGenerator = (function() {
    MainGenerator.prototype.startGenerators = [];

    MainGenerator.prototype.master = null;

    MainGenerator.prototype.nextBuffer = null;

    MainGenerator.prototype.processed = 0;

    function MainGenerator() {
      this.gen = __bind(this.gen, this);
      this.findGenerators();
      this.findMaster();
    }

    MainGenerator.prototype.findGenerators = function() {
      return synth.parts.forEach((function(_this) {
        return function(part, i) {
          if (part.type === "generator") {
            return _this.startGenerators.push(part);
          }
        };
      })(this));
    };

    MainGenerator.prototype.findMaster = function() {
      return synth.parts.forEach((function(_this) {
        return function(part, i) {
          if (part.type === "master") {
            return _this.master = part;
          }
        };
      })(this));
    };

    MainGenerator.prototype.fillNextBuffer = function(buffer, size) {
      var data, i, pos, s, tt, _i, _len, _ref;
      i = 0;
      s = 0;
      tt = 0;
      _ref = buffer[0];
      for (pos = _i = 0, _len = _ref.length; _i < _len; pos = ++_i) {
        data = _ref[pos];
        s = this.master.gen();
        s = (s / 127) - 1;
        s *= 0.5;
        buffer[0][pos] = buffer[1][pos] = s;
        tt++;
      }
      return this.nextBuffer = buffer;
    };

    MainGenerator.prototype.gen = function(e) {
      this.fillNextBuffer(e.buffers, e.bufferSize);
      if (this.nextBuffer == null) {
        return c.l("noBuff");
      }
      e.buffers = this.nextBuffer;
      return this.nextBuffer = null;
    };

    return MainGenerator;

  })();

  manualRun = function(interval) {
    interval = interval || 500;
    return setInterval((function() {
      mainGenerator.master.gen();
      return setTimeout((function() {}), interval / 2);
    }), interval);
  };

  window.inits[400] = {
    desc: "d3 stuff",
    init: function() {
      return initD3Gen();
    }
  };

  addNode = null;

  draw = null;

  initD3Gen = function() {
    var Node, addLink, bh, bw, checkInfinite, color, connectNode, dragPath, edges, force, genLinks, genNodes, genNodesLinks, generatorLength, h, links, nodes, nodesData, r, sourceNode, svg, w;
    window.nodes = nodes = [];
    window.links = links = [];
    nodesData = null;
    h = window.innerHeight - 50;
    w = window.innerWidth - 50;
    svg = d3.select('body').append('svg').attr('height', h).attr('width', w);
    nodesData = svg.append('svg:g').selectAll('g');
    edges = svg.append('svg:g').selectAll('path');
    color = d3.scale.category20();
    c.l(window.innerWidth);
    bw = w / 15;
    bh = h / 15;
    r = 16;
    generatorLength = 0;
    sourceNode = null;
    svg.append('svg:defs').selectAll('marker').data(['end']).enter().append('svg:marker').attr('id', String).attr('viewBox', '0 -5 10 10').attr('refX', 15.5).attr('refY', 0).attr('markerWidth', 14).attr('markerHeight', 6).attr('orient', 'auto').append('svg:path').attr('d', 'M0,-5 L10,0 L0,5 L0,-5');
    dragPath = svg.append('svg:g').append("path").attr("class", "link").attr('marker-end', 'url(#end)');
    Node = (function() {
      function Node(fixed, data, pos) {
        this.data = data;
        this.fixed = fixed;
        this.data.pos = pos;
        this.x = data.type === "master" ? (w / 2) - bw / 2 : w * Math.random();
        if (data.type === "master") {
          this.y = h - bh * 2;
        } else if (data.type === "generator") {
          this.y = bh;
        } else {
          this.y = h * Math.random();
        }
      }

      return Node;

    })();
    addNode = function(part) {
      var fixed;
      fixed = part.type === "master" || part.type === "generator" ? 1 : 0;
      return nodes.push(new Node(fixed, part, nodes.length));
    };
    addLink = function(src, trg) {
      return links.push({
        "source": src.pos,
        "target": trg.pos
      });
    };
    genNodesLinks = function() {
      genNodes();
      return genLinks();
    };
    genNodes = function() {
      return synth.parts.forEach(function(sp, i) {
        return addNode(sp);
      });
    };
    genLinks = function() {
      return nodes.forEach(function(sp, spi) {
        var part;
        part = sp.data;
        if (part.outputs == null) {
          return;
        }
        return sp.data.outputs.forEach(function(output, oi) {
          return addLink(part, output);
        });
      });
    };
    connectNode = function(e) {
      c.l("connect", d3.select(this));
      if (sourceNode == null) {
        d3.select(this).classed("connect", true);
        return sourceNode = e;
      } else {
        if (((sourceNode.data.outputs != null) && (e.data.inputs != null)) && sourceNode !== e) {
          dragPath.attr("d", "M0,0");
          checkInfinite();
          sourceNode.data.outputs.push(e.data);
          e.data.addInput(sourceNode.data);
          genLinks();
          draw();
          mainGenerator.findGenerators();
          sourceNode = null;
          return d3.select(".connect").classed("connect", false);
        }
      }
    };
    checkInfinite = function() {
      var startTrace;
      generatorLength = 0;
      startTrace = function(part) {
        var checkOutputs, visArr;
        visArr = [];
        checkOutputs = function(part, partOld, visited) {
          visited = visited || {};
          if (visited[part.id] != null) {
            partOld.outputs.forEach(function(outOld, i) {
              if (outOld === part) {
                return c.l(partOld.outputs.splice(i, 1));
              }
            });
            return c.l("No loop allowed", part.type, partOld.type);
          }
          if (part.outputs == null) {
            return c.l("no more outs");
          }
          visited[part.id] = part.type;
          visArr.push(part);
          return part.outputs.forEach(function(output, oi) {
            return checkOutputs(output, part, visited);
          });
        };
        return checkOutputs(part);
      };
      return synth.parts.forEach(function(part) {
        if (part.type === "generator") {
          return part.outputs.forEach(function(part) {
            return startTrace(part);
          });
        }
      });
    };
    draw = function() {

      /* Draw the edges/links between the nodes */
      var gnodes;
      edges = edges.data(links);
      edges.enter().append('path').attr("class", "link").attr('marker-end', 'url(#end)');

      /* Draw the nodes themselves */
      nodesData = nodesData.data(nodes);
      gnodes = nodesData.enter().append('g').call(force.drag);
      gnodes.append('line').attr("x1", 0).attr("y1", 0).attr("x2", 0).attr("y2", bh);
      gnodes.append('rect').attr("x", -bw / 2).attr("y", bh).attr('width', bw).attr('height', bh).style('fill', function(d, ni) {
        return color(ni);
      });
      gnodes.append('text').attr('transform', 'translate(' + (-(bw / 2)) + ', ' + (bh * 1.8) + ')').attr('fill', 'black').text(function(d) {
        return d.data.type;
      });
      gnodes.append('circle').attr("r", r).attr("class", "connector").on("click", connectNode);
      edges.exit().remove();
      nodesData.exit().remove();
      return force.start();
    };
    checkInfinite();
    genNodesLinks();

    /* Establish the dynamic force behavor of the nodes */
    force = d3.layout.force().nodes(nodes).links(links).size([w, h]).linkDistance([120]).friction([0.8]).charge([-300]).gravity(0.4).start();
    force.on('tick', function() {
      edges.attr('d', function(d) {
        var x1, x2, y1, y2;
        x1 = d.source.x;
        y1 = d.source.y;
        x2 = d.target.x;
        y2 = d.target.y;
        return 'M' + x1 + ',' + y1 + ' L' + x2 + ',' + y2;
      });
      return nodesData.attr('transform', function(d) {
        return 'translate(' + d.x + ',' + d.y + ')';
      });
    });
    svg.on("mousemove", function(e) {
      var pos;
      if (sourceNode == null) {
        return;
      }
      pos = d3.mouse(this);
      c.l(pos, sourceNode.x);
      return dragPath.attr('d', function(d) {
        var x1, x2, y1, y2;
        x1 = sourceNode.x;
        y1 = sourceNode.y;
        x2 = pos[0] - 2;
        y2 = pos[1] - 2;
        return 'M' + x1 + ',' + y1 + ' L' + x2 + ',' + y2;
      });
    });
    draw();
    return window.draw = draw;
  };

  window.onload = function() {
    return window.inits.forEach(function(init, i) {
      if (init.desc) {
        c.l(init.desc);
      }
      return init.init();
    });
  };

  synth = null;

  window.inits[150] = {
    desc: "init audio generator model",
    init: function() {
      return initModels();
    }
  };

  initModels = function() {
    var Delay, Generator, Master, Mixer, Model;
    Model = (function() {
      Model.prototype.p = 0;

      Model.prototype.lastValues = new Uint8Array;

      Model.prototype.lastValue = 0;

      function Model() {
        this.id = Date.now() + "#" + Math.floor(Math.random() * 999999);
        if (this.outputs != null) {
          this.outputs = [];
        }
        this.inputs = [];
        if (this.init != null) {
          this.init();
        }
      }

      Model.prototype.addInput = function(input) {
        this.updateLastValueArray();
        return this.inputs.push(input);
      };

      Model.prototype.getNewValues = function(newSample) {
        var i, input, returnValue, _i, _len, _ref;
        returnValue = this.lastValue;
        this.lastValue = newSample;
        _ref = this.inputs;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          input = _ref[i];
          this.lastValues[i] = input.gen();
        }
        return returnValue;
      };

      Model.prototype.updateLastValueArray = function() {
        return this.lastValues = new Uint8Array(this.inputs.length + 1);
      };

      Model.prototype.process = function() {
        return 0;
      };

      Model.prototype.gen = function() {
        return this.getNewValues(this.process());
      };

      return Model;

    })();
    Generator = (function() {
      function Generator() {
        this.outputs = [];
      }

      Generator.prototype.type = "generator";

      Generator.prototype.p = 0;

      Generator.prototype.freq = 440;

      Generator.prototype.volume = 0.2;

      Generator.prototype.mute = false;

      Generator.prototype.outputs = [];

      Generator.prototype.gen = function() {
        var s;
        this.p += this.freq * 256 / 44100;
        s = this.p & this.p >> 8;
        s = (((s & 255) - 127) * this.volume) + 127;
        return s;
      };

      return Generator;

    })();
    Mixer = (function(_super) {
      __extends(Mixer, _super);

      function Mixer() {
        return Mixer.__super__.constructor.apply(this, arguments);
      }

      Mixer.prototype.type = "mixer";

      Mixer.prototype.activeMixer = "&";

      Mixer.prototype.outputs = [];

      Mixer.prototype.inputBuffer = 0;

      Mixer.prototype.mixBuffer = null;

      Mixer.prototype.process = function() {
        var i, s, v, _i, _len, _ref;
        s = void 0;
        _ref = this.lastValues;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          v = _ref[i];
          s = this.mixers[this.activeMixer](v, s);
        }
        return s;
      };

      Mixer.prototype.mixers = {
        "|": function(a, b) {
          return a | b || 0;
        },
        "M": function(a, b) {
          return (a + b || 127) / 2;
        },
        "m": function(a, b) {
          return (a * b || 127) >> 8;
        },
        "&": function(a, b) {
          return a & b || 255;
        },
        "^": function(a, b) {
          return a ^ b || 0;
        },
        "+": function(a, b) {
          return a + b || 0;
        },
        "-": function(a, b) {
          return a - b || 0;
        },
        "*": function(a, b) {
          return a * b || 1;
        },
        "/": function(a, b) {
          return a / b || 1;
        }
      };

      return Mixer;

    })(Model);
    Delay = (function(_super) {
      __extends(Delay, _super);

      function Delay() {
        return Delay.__super__.constructor.apply(this, arguments);
      }

      Delay.prototype.init = function() {
        this.buffer = new Uint8Array(Pico.sampleRate * this.seconds);
        return this.p = 1;
      };

      Delay.prototype.type = "delay";

      Delay.prototype.dry = 0.5;

      Delay.prototype.wet = 0.5;

      Delay.prototype.seconds = 0.4;

      Delay.prototype.buffer = null;

      Delay.prototype.outputs = [];

      Delay.prototype.process = function() {
        var bufSmpl, smpl;
        smpl = this.lastValues[0];
        bufSmpl = this.buffer[this.p];
        if (this.p < this.buffer.length - 1) {
          this.p++;
        } else {
          this.p = 1;
        }
        this.buffer[this.p - 1] = smpl;
        smpl = smpl * this.dry + bufSmpl * this.wet;
        return smpl;
      };

      return Delay;

    })(Model);
    Master = (function(_super) {
      __extends(Master, _super);

      function Master() {
        return Master.__super__.constructor.apply(this, arguments);
      }

      Master.prototype.type = "master";

      Master.prototype.process = function() {
        var i, s, v, _i, _len, _ref;
        s = 0;
        _ref = this.lastValues;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          v = _ref[i];
          s += v - 127;
        }
        if (s > 128) {
          s = 128;
        } else if (s < -127) {
          s = -127;
        }
        return s + 127;
      };

      return Master;

    })(Model);
    return synth = {
      parts: [],
      partClasses: {
        Generator: Generator,
        Delay: Delay,
        Mixer: Mixer,
        Master: Master
      }
    };
  };

  window.inits[300] = {
    desc: "Audiogenerator",
    init: function() {}
  };

  SAMPLERATE = 8000;

  BUFFERLENGTH = 16384;

  CHANNELS = 2;

  frequency = 0;

  document.addEventListener("mousemove", function(e) {
    return frequency = e.pageX;
  });

  initWebAudio = function() {
    var audioCtx, bufferCtx, offlineBuffer, offlineCtx, offlineScriptNode, scriptNode, t;
    audioCtx = new AudioContext;
    offlineCtx = new OfflineAudioContext(CHANNELS, BUFFERLENGTH, SAMPLERATE);
    scriptNode = audioCtx.createScriptProcessor(BUFFERLENGTH, 0, CHANNELS);
    offlineScriptNode = offlineCtx.createScriptProcessor(BUFFERLENGTH, 0, CHANNELS);
    bufferCtx = audioCtx.createBufferSource();
    offlineBuffer = offlineCtx.createBufferSource();
    t = 0;
    scriptNode.onaudioprocess = function(e) {
      var channel, outputBuffer, outputData, p, s, sample, _results;
      c.l("process--------------------------------");
      outputBuffer = e.outputBuffer;
      channel = 0;
      _results = [];
      while (channel < outputBuffer.numberOfChannels) {
        outputData = outputBuffer.getChannelData(channel);
        sample = 0;
        while (sample < outputBuffer.length) {
          p = (frequency * 255) / SAMPLERATE;
          s = t & t % 255.5;
          outputData[sample] = (((s & 255) / 128) - 1) * 0.3;
          sample++;
          t += p;
        }
        _results.push(channel++);
      }
      return _results;
    };
    offlineCtx.oncomplete = function(e) {
      console.log('Rendering completed successfully', e);
      c.l(e.renderedBuffer.getChannelData(0));
      return bufferCtx.buffer = e.renderedBuffer;
    };
    return scriptNode.connect(audioCtx.destination);
  };

}).call(this);

//# sourceMappingURL=main.js.map
