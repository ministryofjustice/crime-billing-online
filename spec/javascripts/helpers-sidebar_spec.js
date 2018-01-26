describe('Helpers.SideBar.js', function() {
  it('should exist with expected constructors', function() {
    expect(moj.Helpers.SideBar).toBeDefined();
    expect(moj.Helpers.SideBar.Base).toBeDefined();
    expect(moj.Helpers.SideBar.FeeBlock).toBeDefined();
    expect(moj.Helpers.SideBar.FeeBlockCalculator).toBeDefined();
  });

  describe('Methods', function() {
    describe('...addCommas', function() {
      it('should format the numbers correctly', function() {
        var expected = {
          0: '0.01',
          1: '0.11',
          2: '1.11',
          3: '11.11',
          4: '111.11',
          5: '1,111.11',
          6: '11,111.11',
          7: '111,111,111.11'
        };

        ['0.01', '0.11', '1.11', '11.11', '111.11', '1111.11', '11111.11', '111111111.11'].forEach(function(val, idx) {
          expect(expected[idx]).toBe(moj.Helpers.SideBar.addCommas(val));
        });
      });
    });
  });

  describe('Instances', function() {
    var instance;
    beforeEach(function() {});

    describe('Base', function() {
      it('should have defaults set', function() {
        instance = new moj.Helpers.SideBar.Base();
        expect(instance.config).toEqual({
          type: '_Base',
          vatfactor: 0.2,
          autoVAT: false
        });
      });

      it('should take an `options` object and overide', function() {
        instance = new moj.Helpers.SideBar.Base({
          type: 'TYPE',
          vatfactor: 99,
          autoVAT: false
        });
        expect(instance.config).toEqual({
          type: 'TYPE',
          vatfactor: 99,
          autoVAT: false
        });
      });

      it('should cache referances to the DOM element', function() {
        var fixtureDom = ['<div class="js-block">', '<span>hello</span>', '</div>'].join('');
        $('body').append(fixtureDom);
        instance = new moj.Helpers.SideBar.Base({
          $el: $('.js-block'),
          el: fixtureDom
        });
        expect(instance.$el).toEqual($('.js-block'));
        expect(instance.el).toEqual(fixtureDom);
        $('.js-block').remove();
      });

      describe('Methods', function() {
        describe('...getConfig', function() {
          it('should return the correct `this.config` prop', function() {
            instance = new moj.Helpers.SideBar.Base({
              some: 'thing'
            });
            expect(instance.getConfig('type')).toBe('_Base');
            expect(instance.getConfig('some')).toBe('thing');
          });
        });

        describe('...updateTotals', function() {
          it('should return a info message', function() {
            instance = new moj.Helpers.SideBar.Base();
            expect(instance.updateTotals()).toBe('This method needs an override');
          });
        });

        describe('...isVisible', function() {
          it('should correctly return the `isVisible` status', function() {
            var fixtureDom = [
              '<div class="js-block">',
              '<span class="rate">rate</span>',
              '<span class="amount">amount</span>',
              '<span class="total">total</span>',
              '</div>'
            ].join('');
            $('body').append(fixtureDom);
            instance = new moj.Helpers.SideBar.Base({
              $el: $('.js-block'),
              el: fixtureDom
            });
            expect(instance.isVisible()).toBe(true);
            instance.$el.find('.rate').hide();
            expect(instance.isVisible()).toBe(true);
            instance.$el.find('.amount').hide();
            expect(instance.isVisible()).toBe(true);
            instance.$el.find('.total').hide();
            expect(instance.isVisible()).toBe(false);
            $('.js-block').remove();
          });
        });

        describe('...applyVat', function() {
          it('should not apply 20% VAT by default', function() {
            instance = new moj.Helpers.SideBar.Base();
            instance.totals = {
              vat: 0,
              total: 100
            };
            instance.applyVat();
            expect(instance.totals.vat).toBe(0);
          });

          it('should not apply VAT if `autoVAT` is false', function() {
            instance = new moj.Helpers.SideBar.Base({
              autoVAT: false
            });
            instance.totals = {
              vat: 0,
              total: 100
            };
            instance.applyVat();
            expect(instance.totals.vat).toBe(0);
          });

          it('should use a configurable `config.vatfactor`', function() {
            instance = new moj.Helpers.SideBar.Base({
              vatfactor: 0.5,
              autoVAT: true
            });
            instance.totals = {
              vat: 0,
              total: 100
            };
            instance.applyVat();
            expect(instance.totals.vat).toBe(50);
          });
        });

        describe('...getVal', function() {
          beforeEach(function() {
            var fixtureDom = [
              '<div class="js-block">',
              '<input class="rate" value="22.22"/>',
              '<input class="amount" value="33.33"/>',
              '</div>'
            ].join('');
            $('body').append(fixtureDom);
            instance = new moj.Helpers.SideBar.Base({
              $el: $('.js-block'),
              el: fixtureDom
            });
          });

          afterEach(function() {
            $('.js-block').remove();
          });

          it('should return the input value given a selector', function() {
            expect(instance.getVal('.rate')).toBe(22.22);
            expect(instance.getVal('.amount')).toBe(33.33);
          });

          it('should return 0 if no value is found', function() {
            $('.js-block').find('.amount').remove();
            expect(instance.getVal('.amount')).toBe(0);
          });
        });

        describe('...getDataVal', function() {
          beforeEach(function() {
            var fixtureDom = [
              '<div class="js-block">',
              '<input class="total" data-total="44.44" value="44.44"/>',
              '</div>'
            ].join('');
            $('body').append(fixtureDom);
            instance = new moj.Helpers.SideBar.Base({
              $el: $('.js-block'),
              el: fixtureDom
            });
          });

          afterEach(function() {
            $('.js-block').remove();
          });

          it('should return the input value given a selector', function() {
            expect(instance.getDataVal('total')).toBe(44.44);
          });

          it('should return `false` if no value is found', function() {
            $('.js-block').find('.total').remove();
            expect(instance.getDataVal('total')).toBe(false);
          });
        });
      });
    });

    describe('FeeBlock', function() {
      it('should apply Base Methods and set config props on the instance', function() {
        var fixtureDom = [
          '<div class="js-block">',
          '</div>'
        ].join('');
        $('body').append(fixtureDom);
        instance = new moj.Helpers.SideBar.FeeBlock({
          type: 'FeeBlock',
          $el: $('.js-block'),
          el: fixtureDom
        });
        expect(instance.getConfig).toBeDefined();
        expect(instance.getConfig('type')).toEqual('FeeBlock');
        $('.js-block').remove();
      });

      describe('Methods', function() {
        var fixtureDom;
        beforeEach(function() {
          fixtureDom = [
            '<div class="js-block">',
            '<input class="quantity" value="11.11"/>',
            '<input class="rate" value="22.22"/>',
            '<input class="amount" value="33.33"/>',
            '<span class="total" data-total="44.44" />',
            '<input class="vat" value=""/>',
            '</div>'
          ].join('');
          $('body').append(fixtureDom);
          instance = new moj.Helpers.SideBar.FeeBlock({
            $el: $('.js-block'),
            el: fixtureDom
          });
        });

        afterEach(function() {
          $('.js-block').remove();
        });

        describe('...init', function() {
          it('should call `this.bindRecalculate`', function() {
            spyOn(instance, 'bindRecalculate');
            instance.init();
            expect(instance.bindRecalculate).toHaveBeenCalled();
          });
          it('should call `this.reload`', function() {
            spyOn(instance, 'reload');
            instance.init();
            expect(instance.reload).toHaveBeenCalled();
          });
        });

        describe('...bindRecalculate', function() {
          it('should bind a change event on specific elements', function() {
            spyOn(instance.$el, 'on');
            instance.bindRecalculate();
            expect(instance.$el.on).toHaveBeenCalledWith('change', '.quantity, .rate, .amount, .vat, .total', jasmine.any(Function));
          });

          it('should trigger the `recalculate` event when `change` is fired', function() {
            spyOn(instance.$el, 'trigger');
            instance.bindRecalculate();
            instance.$el.find('.rate').trigger('change');
            expect(instance.$el.trigger).toHaveBeenCalledWith('recalculate');
          });
        });

        describe('...reload', function() {
          it('should call `updateTotals`', function() {
            spyOn(instance, 'updateTotals');
            instance.reload();

            expect(instance.updateTotals).toHaveBeenCalled();
          });

          it('should call `applyVat`', function() {
            spyOn(instance, 'applyVat');
            instance.reload();

            expect(instance.applyVat).toHaveBeenCalled();
          });

          it('should call reload when instantiated', function() {
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 22.22,
              amount: 33.33,
              total: 44.44,
              vat: 0,
              typeTotal: 44.44
            });
          });
        });

        describe('...setTotals', function() {

          it('should return an updated `this.totals` object', function() {
            instance.$el.find('.rate').val('222.22');
            instance.$el.find('.amount').val('333.33');
            instance.$el.find('.total').data('total', '444.44');

            instance.setTotals();
            // console.log(instance);
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 222.22,
              amount: 333.33,
              total: 444.44,
              vat: 0,
              typeTotal: 444.44
            });
          });

          it('should handle missing `data-total` on the element', function() {
            instance.$el.find('.rate').val('222.22');
            instance.$el.find('.amount').val('333.33');
            instance.$el.find('.total').remove();
            instance.$el.append('<input class="total" />');
            instance.$el.find('.total').val('555.55');

            instance.setTotals();
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 222.22,
              amount: 333.33,
              total: 555.55,
              vat: 0,
              typeTotal: 555.55
            });
          });
        });

        describe('...updateTotals', function() {
          var called = false;

          it('should call `this.isVisible`', function() {
            instance.isVisible = function() {
              called = true;
            };
            instance.updateTotals();
            expect(called).toBe(true);
          });

          it('should return the current `this.totals` when element is hidden', function() {
            instance.totals = {
              current: 'total'
            };
            spyOn(instance, 'isVisible').and.returnValue(false);
            expect(instance.updateTotals()).toEqual({
              current: 'total'
            });
          });

          it('should call `this.setTotals` when `this.isVisible` returns true', function() {
            instance.totals = {
              current: 'total'
            };
            spyOn(instance, 'isVisible').and.returnValue(true);
            spyOn(instance, 'setTotals').and.returnValue('david');

            instance.updateTotals();

            expect(instance.isVisible).toHaveBeenCalled();
            expect(instance.setTotals).toHaveBeenCalled();

          });
        });
      });
    });

    describe('FeeBlockCalculator', function() {
      it('should apply Base Methods and set config props on the instance', function() {
        var fixtureDom = [
          '<div class="js-block">',
          '</div>'
        ].join('');
        $('body').append(fixtureDom);
        instance = new moj.Helpers.SideBar.FeeBlockCalculator({
          type: 'FeeBlockCalculator',
          $el: $('.js-block'),
          el: fixtureDom
        });
        expect(instance.setTotals).toBeDefined();
        expect(instance.bindRender).toBeDefined();
        expect(instance.init).toBeDefined();
        expect(instance.render).toBeDefined();
        $('.js-block').remove();

      });

      describe('Methods', function() {
        var fixtureDom;
        beforeEach(function() {
          fixtureDom = [
            '<div class="js-block">',
            '<input class="quantity" value="11.11"/>',
            '<input class="rate" value="22.22"/>',
            '<input class="amount" value="33.33"/>',
            '<span class="total" data-total="44.44" />',
            '<input class="vat" value="88.88"/>',
            '</div>'
          ].join('');
          $('body').append(fixtureDom);
          instance = new moj.Helpers.SideBar.FeeBlockCalculator({
            $el: $('.js-block'),
            el: fixtureDom
          });
        });

        afterEach(function() {
          $('.js-block').remove();
        });

        describe('...init', function() {
          it('should call `this.bindRender`', function() {
            spyOn(instance, 'bindRender');
            instance.init();
            expect(instance.bindRender).toHaveBeenCalled();
          });
        });

        describe('...render', function() {
          it('should update the view correctly', function(){
            instance.totals.total = 1234567.89;
            instance.render();
            expect(instance.$el.find('.total').data('total')).toBe(1234567.89);
            expect(instance.$el.find('.total').html()).toEqual('£1,234,567.89');
          });
        });

        describe('...setTotals', function() {
          it('should set `this.totals` correctly', function(){
            instance.totals = {
              quantity: 'changeme',
              rate: 'changeme',
              amount: 'changeme',
              total: 'changeme',
              vat: 'changeme'
            };
            instance.setTotals();
            expect(instance.totals).toEqual({
              quantity: 11.11,
              rate: 22.22,
              amount: 33.33,
              total: 246.86,
              vat: 88.88,
              typeTotal: 246.86
            });
          });
        });

        describe('...bindRender', function() {
          it('should bind a change event on specific elements', function() {
            spyOn(instance.$el, 'on');
            instance.bindRender();
            expect(instance.$el.on).toHaveBeenCalledWith('change', '.quantity, .rate', jasmine.any(Function));
          });

          it('should call `this.updateTotals` when `change` is fired', function() {
            spyOn(instance, 'updateTotals');
            instance.bindRender();
            instance.$el.find('.rate').trigger('change');
            expect(instance.updateTotals).toHaveBeenCalled();
          });

          it('should call `this.render` when `change` is fired', function() {
            spyOn(instance, 'render');
            instance.bindRender();
            instance.$el.find('.rate').trigger('change');
            expect(instance.render).toHaveBeenCalled();
          });
        });
      });
    });
  });
});