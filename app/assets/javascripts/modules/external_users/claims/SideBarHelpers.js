moj.Helpers.SideBar = {
  Base: function(options) {
    var _options = {
      type: '_Base',
      vatfactor: 0.2,
      autoVAT: true
    };
    this.config = $.extend({}, _options, options);
    this.$el = this.config.$el;
    this.el = this.config.el;

    this.getConfig = function(key) {
      return this.config[key] || undefined;
    };

    this.updateTotals = function() {
      return 'This method needs an override';
    };

    this.isVisible = function() {
      return this.$el.find('.rate').is(':visible') || this.$el.find('.amount').is(':visible') || this.$el.find('.total').is(':visible');
    };

    this.applyVat = function() {
      if (this.config.autoVAT) {
        this.totals.vat = this.totals.total * this.config.vatfactor;
      }
    };

    this.getVal = function(selector) {
      return parseFloat(this.$el.find(selector).val()) || 0;
    };

    this.getDataVal = function(selector) {
      return parseFloat(this.$el.find('.' + selector).data('total')) || false;
    };
  },
  FeeBlock: function() {
    var self = this;
    // copy methods over
    moj.Helpers.SideBar.Base.apply(this, arguments);
    this.totals = {
      quantity: 0,
      rate: 0,
      amount: 0,
      total: 0,
      vat: 0
    };

    this.init = function() {
      this.bindRecalculate();
      this.reload();
    };

    this.bindRecalculate = function() {
      this.$el.on('change', '.quantity, .rate, .amount, .vat, .total', function(e) {
        self.$el.trigger('recalculate');
      });
    };

    this.reload = function() {
      this.updateTotals();
      this.applyVat();
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: this.getDataVal('total') || this.getVal('.total'),
        vat: this.getVal('.vat')
      };
      return this.totals;
    };

    this.updateTotals = function(a) {
      if (!this.isVisible()) {
        return this.totals;
      }
      return this.setTotals();
    };
    this.init();
  },
  FeeBlockCalculator: function() {
    var self = this;
    moj.Helpers.SideBar.FeeBlock.apply(this, arguments);

    this.init = function() {
      this.bindRender();
    };

    this.render = function() {
      this.$el.find('.total').html('&pound;' + moj.Helpers.SideBar.addCommas(this.totals.total.toFixed(2)));
      this.$el.find('.total').data('total', this.totals.total);
    };

    this.setTotals = function() {
      this.totals = {
        quantity: this.getVal('.quantity'),
        rate: this.getVal('.rate'),
        amount: this.getVal('.amount'),
        total: parseFloat((this.getVal('.quantity') * this.getVal('.rate')).toFixed(2)),
        vat: this.getVal('.vat')
      };
      return this.totals;
    };

    this.bindRender = function() {
      this.$el.on('change', '.quantity, .rate', function() {
        self.updateTotals();
        self.render();
      });
    };

    this.init();
  },
  addCommas: function(nStr) {
    nStr += '';
    x = nStr.split('.');
    x1 = x[0];
    x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
  },
};