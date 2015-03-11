var Dashboard,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

if (typeof Dashboard === "undefined" || Dashboard === null) {
  window.Dashboard = {};
}

Dashboard = (function() {
  function Dashboard(config) {
    var i, len, name, ref, widget, widgetConfig;
    if (config.widgets) {
      this.widgetCollection = new Dashboard.Widgets([], config);
      ref = config.widgets;
      for (i = 0, len = ref.length; i < len; i++) {
        widgetConfig = ref[i];
        name = Dashboard.widgets[widgetConfig.name] != null ? widgetConfig.name : 'standart';
        widget = new Dashboard.widgets[name](_.extend({
          _dataId: widgetConfig.dataId,
          id: widgetConfig.dataId
        }, widgetConfig.extra));
        this.widgetCollection.add(widget);
      }
    } else {
      this.widgetCollection = new Dashboard.WidgetsServerConfig([], config);
    }
  }

  return Dashboard;

})();

Dashboard.Widgets = Backbone.Collection.extend({
  initialize: function(models, config1) {
    this.config = config1;
    this.client = new Dashboard.Client(this.config);
    this.view = new Dashboard.View({
      collection: this
    });
    return this.listenTo(this.client, 'dataUpdated', function(changed) {
      console.log('changed', changed);
      return this.prepareData(changed);
    });
  },
  prepareData: function(data) {
    var dataSet, model, results;
    results = [];
    for (dataSet in data) {
      model = this.find(function(model) {
        return model.get('_dataId') === dataSet;
      });
      if (model) {
        results.push(model.set({
          value: data[dataSet],
          last_update: new Date()
        }));
      } else {
        results.push(void 0);
      }
    }
    return results;
  }
});

Dashboard.WidgetsServerConfig = Dashboard.Widgets.extend({
  prepareData: function(data) {
    var i, len, name, ref, results, widget, widgetModel;
    if (data.widgets) {
      ref = data.widgets;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        widget = ref[i];
        name = Dashboard.widgets[widget.name] != null ? widget.name : 'standart';
        widget.id = widget.dataId;
        widgetModel = new Dashboard.widgets[name](_.extend(widget, {
          last_update: new Date()
        }));
        results.push(this.set(widgetModel));
      }
      return results;
    }
  }
});

Dashboard.widgets = {};


/*
For future
Dashboard.templates = {}
 */

Dashboard.utils = {
  getGuid: function() {
    var s4;
    s4 = function() {
      return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    };
    return "" + (s4()) + (s4()) + "-" + (s4()) + "-" + (s4()) + "-" + (s4()) + "-" + (s4()) + (s4()) + (s4());
  },
  shortenedNumber: function(num) {
    var newNum;
    if (isNaN(num)) {
      return num;
    }
    newNum = num;
    if (num >= 1000000000) {
      newNum = (num / 1000000000).toFixed(1) + 'B';
    } else if (num >= 1000000) {
      newNum = (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
      newNum = (num / 1000).toFixed(1) + 'K';
    } else {
      newNum = num;
    }
    return newNum.toString().replace(/\B(?=(\d{3})+(?!\d))/g, "&thinsp;");
  },
  animateValue: function(oldValue, value, renderFn) {
    var delay, difference, iterations, step, timeout, to, trendUp;
    if ((value == null) || isNaN(value)) {
      return false;
    }
    timeout = 700;
    delay = 20;
    iterations = timeout / delay;
    difference = value - oldValue;
    trendUp = oldValue < value;
    step = Math.ceil(difference / 50);
    return to = setInterval(function() {
      oldValue += step;
      if ((trendUp && oldValue >= value) || (!trendUp && oldValue <= value)) {
        oldValue = value;
        clearInterval(to);
      }
      return typeof renderFn === "function" ? renderFn(oldValue) : void 0;
    }, delay);
  }
};

Dashboard.Client = (function(superClass) {
  extend(Client, superClass);

  function Client() {
    return Client.__super__.constructor.apply(this, arguments);
  }

  Client.prototype.initialize = function(config1) {
    this.config = config1;
    this.connect();
    return this.on('change', function() {
      return this.trigger('dataUpdated', this.changed);
    });
  };

  Client.prototype.url = function(config) {
    return config.url;
  };

  Client.prototype.connect = function() {
    this._ws = new WebSocket(this.url(this.config));
    this._bindWs();
    if (this.config.updateTime) {
      return this._updater();
    }
  };

  Client.prototype._bindWs = function() {
    this._ws.onopen = (function(_this) {
      return function() {
        _this._ws.onmessage = function(message) {
          return _this.set(_this.parse(message.data));
        };
        if (_this.config.updateTime) {
          return _this.update();
        }
      };
    })(this);
    return this._ws.onerror = (function(_this) {
      return function() {
        return _this._reconnect();
      };
    })(this);
  };

  Client.prototype._updater = function() {
    return this._updaterTO = setTimeout((function(_this) {
      return function() {
        _this.update();
        return _this._updater();
      };
    })(this), this.config.updateTime);
  };

  Client.prototype._reconnect = function() {
    console.log('Connection error');
    return setTimeout((function(_this) {
      return function() {
        return _this.connect();
      };
    })(this), 2000);
  };

  Client.prototype.update = function() {
    var udid;
    udid = Dashboard.utils.getGuid();
    return this._ws.send(JSON.stringify(_.extend({
      tag: udid
    }, this.config.socketData)));
  };

  Client.prototype.parse = function(data) {
    if (typeof data === 'string') {
      data = JSON.parse(data);
    }
    if (_.isArray(data.result)) {
      data = {
        widgets: data.result
      };
    }
    return data.result;
  };

  return Client;

})(Backbone.Model);

Dashboard.View = (function(superClass) {
  extend(View, superClass);

  function View() {
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.el = 'body';

  View.prototype.template = '<div class="container w-<%= grid.w %> h-<%= grid.h %>"></div>';

  View.prototype.widgetTemplate = '<div class="element"><div class="element-wrap"></div></div>';

  View.prototype.presets = [
    {
      min: 1,
      w: 1,
      h: 1
    }, {
      min: 2,
      w: 2,
      h: 1
    }, {
      min: 3,
      w: 2,
      h: 2
    }, {
      min: 5,
      w: 4,
      h: 2
    }, {
      min: 9,
      w: 3,
      h: 3
    }, {
      min: 10,
      w: 4,
      h: 3
    }, {
      min: 13,
      w: 5,
      h: 3
    }, {
      min: 16,
      w: 4,
      h: 4
    }, {
      min: 17,
      w: 5,
      h: 4
    }
  ];

  View.prototype.initialize = function() {
    return this.listenTo(this.collection, 'add', this.render);
  };

  View.prototype.render = function() {
    var $container, $widget, grid, i, j, len, len1, model, preset, ref, ref1;
    grid = _.first(this.presets);
    ref = this.presets;
    for (i = 0, len = ref.length; i < len; i++) {
      preset = ref[i];
      console.log('ss', preset.w + "x" + preset.h, this.collection.length, preset.min, preset.min > this.collection.length);
      if (preset.min > this.collection.length) {
        break;
      }
      grid = preset;
    }
    console.log(_.template(this.template)({
      grid: grid
    }));
    $container = $(_.template(this.template)({
      grid: grid
    }));
    ref1 = this.collection.models;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      model = ref1[j];
      if (model.view) {
        $widget = $(this.widgetTemplate);
        $widget.find('.element-wrap').html(model.view.$el);
        $container.append($widget);
      }
    }
    return this.$el.html($container);
  };

  return View;

})(Backbone.View);

Dashboard.widgets.standart = Backbone.Model.extend({
  defaults: function() {
    return {
      value: 0
    };
  },
  initialize: function() {
    return this.view = new Dashboard.widgets.standartView({
      model: this,
      id: this.id
    });
  }
});

Dashboard.widgets.standartView = Backbone.View.extend({
  className: 'widget',
  template: '<div class="title"><%= label %></div><span class="value"><%= value %></span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>',
  initialize: function() {
    this.listenTo(this.model, 'change', this.render);
    return this.render();
  },
  getData: function() {
    return this.model.toJSON();
  },
  render: function() {
    var classes, data, statuses;
    data = this.getData();
    this.$el.html(_.template(this.template)(data));
    classes = this.$el.attr('class');
    statuses = _.filter(classes.split(' '), function(className) {
      return className.indexOf('mStatus_') > -1;
    });
    this.$el.removeClass(statuses.join(' '));
    if (data.status) {
      return this.$el.addClass('mStatus_' + data.status);
    }
  }
});

var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Dashboard.widgets.meter = (function(superClass) {
  extend(meter, superClass);

  function meter() {
    return meter.__super__.constructor.apply(this, arguments);
  }

  meter.prototype.initialize = function() {
    return this.view = new Dashboard.widgets.meterView({
      model: this,
      id: this.id
    });
  };

  return meter;

})(Dashboard.widgets.standart);

Dashboard.widgets.meterView = (function(superClass) {
  extend(meterView, superClass);

  function meterView() {
    return meterView.__super__.constructor.apply(this, arguments);
  }

  meterView.prototype.className = 'widget meter';

  meterView.prototype.template = '<div class="title"><%= label %></div><input type="text" class="value" value="<%= value %>"><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>';

  meterView.prototype.render = function() {
    var data;
    meterView.__super__.render.call(this);
    data = this.getData();
    return this.$el.find('.value').knob({
      angleArc: 270,
      angleOffset: 225,
      readOnly: true,
      max: data.mas,
      value: data.value,
      width: '50%',
      height: '50%',
      fgColor: this.$el.find('.value').css('color'),
      bgColor: this.$el.find('.value').css('background-color')
    });
  };

  return meterView;

})(Dashboard.widgets.standartView);

var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Dashboard.widgets.number = (function(superClass) {
  extend(number, superClass);

  function number() {
    return number.__super__.constructor.apply(this, arguments);
  }

  number.prototype.initialize = function() {
    return this.view = new Dashboard.widgets.numberView({
      model: this,
      id: this.id
    });
  };

  number.prototype.getTrend = function() {
    var pervious;
    if (this._previousAttributes.value) {
      pervious = this._previousAttributes;
      return this.get('value') - pervious;
    }
    return 0;
  };

  return number;

})(Dashboard.widgets.standart);

Dashboard.widgets.numberView = (function(superClass) {
  extend(numberView, superClass);

  function numberView() {
    return numberView.__super__.constructor.apply(this, arguments);
  }

  numberView.prototype.className = 'widget number';

  numberView.prototype.getData = function() {
    var data;
    data = this.model.toJSON();
    data.value = Dashboard.utils.shortenedNumber(data.value);
    return data;
  };

  return numberView;

})(Dashboard.widgets.standartView);

var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Dashboard.widgets.percentage = (function(superClass) {
  extend(percentage, superClass);

  function percentage() {
    return percentage.__super__.constructor.apply(this, arguments);
  }

  percentage.prototype.defaults = function() {
    return {
      label: '',
      value: {
        large: {
          current: 1
        },
        all: {
          current: 1
        }
      }
    };
  };

  percentage.prototype.initialize = function() {
    return this.view = new Dashboard.widgets.percentageView({
      model: this,
      id: this.id
    });
  };

  percentage.prototype.getTrend = function() {
    var current, pervious;
    if (this._previousAttributes.value) {
      pervious = this._previousAttributes.value;
      current = this.get('value');
      return (current.large.current / current.all.current - pervious.large.current / pervious.all.current) * 100;
    }
    return 0;
  };

  percentage.prototype.toJSON = function() {
    var data;
    data = _.extend({}, this.attributes);
    data.value = {
      dividend: data.value.large.current,
      divider: data.value.all.current
    };
    return data;
  };

  return percentage;

})(Dashboard.widgets.standart);

Dashboard.widgets.percentageView = (function(superClass) {
  extend(percentageView, superClass);

  function percentageView() {
    return percentageView.__super__.constructor.apply(this, arguments);
  }

  percentageView.prototype.className = 'widget percentage';

  percentageView.prototype.getData = function() {
    var data;
    data = this.model.toJSON();
    data.value = data.value.dividend / data.value.divider;
    data.value = Math.round(data.value * 10000) / 100 + '%';
    return data;
  };

  return percentageView;

})(Dashboard.widgets.standartView);

var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Dashboard.widgets.piechart = (function(superClass) {
  extend(piechart, superClass);

  function piechart() {
    return piechart.__super__.constructor.apply(this, arguments);
  }

  piechart.prototype.defaults = function() {
    return {
      label: '',
      value: []
    };
  };

  piechart.prototype.initialize = function() {
    return this.view = new Dashboard.widgets.piechartView({
      model: this,
      id: this.id
    });
  };

  return piechart;

})(Dashboard.widgets.standart);

Dashboard.widgets.piechartView = (function(superClass) {
  extend(piechartView, superClass);

  function piechartView() {
    return piechartView.__super__.constructor.apply(this, arguments);
  }

  piechartView.prototype.className = 'widget piechart';

  piechartView.prototype.template = '<div class="title"><%= label %></div><span class="value"></span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>';

  piechartView.prototype.render = function() {
    var arc, arcs, center_label, chart, color, data, dataFull, height, label_group, label_radius, legend, node, pie, pieData, radius, rectSize, width;
    piechartView.__super__.render.call(this);
    dataFull = this.getData();
    data = dataFull.value;
    width = 225;
    height = 225;
    radius = 112;
    label_radius = 110;
    color = d3.scale.category20();
    node = this.$el.find('.value')[0];
    $(node).children("svg").remove();
    if (data.length > 0) {
      pieData = $.extend(true, [], data);
      if (dataFull.firstAll) {
        pieData[0].value = 0;
      }
      chart = d3.select(node).append("svg:svg").data([pieData]).attr("width", width).attr("height", height).append("svg:g").attr("transform", "translate(" + radius + " , " + radius + ")");
      if (dataFull.firstAll) {
        label_group = chart.append("svg:g").attr("dy", ".6em");
        center_label = label_group.append("svg:text").attr("class", "chart_label").attr("text-anchor", "middle").attr('fill', '#ffffff').text(data[0].label + ' ' + data[0].value);
      }
      arc = d3.svg.arc().innerRadius(radius * .6).outerRadius(radius);
      pie = d3.layout.pie().value(function(d) {
        return d.value;
      });
      arcs = chart.selectAll("g.slice").data(pie).enter().append("svg:g").attr("class", "slice");
      arcs.append("svg:path").attr("fill", function(d, i) {
        if (!(i === 0 && dataFull.firstAll)) {
          return color(i);
        }
      }).attr("d", arc);
      rectSize = 18;
      legend = d3.select(node).append("svg:svg").attr("class", "legend").attr("x", 0).attr("y", 0).attr("height", (rectSize + 4) * data.length).attr('width', '380');
      return legend.selectAll("g").data(data).enter().append("g").each(function(d, i) {
        var g;
        if (i === 0 && dataFull.firstAll) {
          return;
        }
        g = d3.select(this);
        g.append("rect").attr("x", 0).attr("y", i * (rectSize + 4)).attr("width", rectSize - 1).attr("height", rectSize - 1).attr("fill", color(i));
        return g.append("text").attr("x", rectSize + 4).attr("y", (i + 1) * (rectSize + 4) - 6).attr("font-size", (rectSize - 1) + "px").attr('fill', '#ffffff').text(d.label + " " + d.value);
      });
    }
  };

  return piechartView;

})(Dashboard.widgets.standartView);

var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Dashboard.widgets.table = (function(superClass) {
  extend(table, superClass);

  function table() {
    return table.__super__.constructor.apply(this, arguments);
  }

  table.prototype.initialize = function() {
    console.log('tableView');
    return this.view = new Dashboard.widgets.tableView({
      model: this,
      id: this.id
    });
  };

  return table;

})(Dashboard.widgets.standart);

Dashboard.widgets.tableView = (function(superClass) {
  extend(tableView, superClass);

  function tableView() {
    return tableView.__super__.constructor.apply(this, arguments);
  }

  tableView.prototype.className = 'widget table';

  tableView.prototype.template = '<div class="title"><%= label %></div><span class="value"></span><% if(typeof last_update != \'undefined\'){ %><div class="helpline">Last updated: <% print(last_update.toLocaleTimeString()) %></div><% } %>';

  tableView.prototype.render = function() {
    var data, i, len, ref, row, table;
    data = this.getData();
    this.$el.html(_.template(this.template)(data));
    table = $('<table></table>');
    ref = data.value;
    for (i = 0, len = ref.length; i < len; i++) {
      row = ref[i];
      table.append("<tr><td>" + row.label + "</td><td>" + row.value + "</td></tr>");
    }
    return this.$el.find('.value').html(table);
  };

  return tableView;

})(Dashboard.widgets.standartView);
