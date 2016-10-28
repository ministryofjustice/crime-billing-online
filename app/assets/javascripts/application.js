//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require cocoon
//= require dropzone
//= require vendor/polyfills/bind
//= require govuk/selection-buttons
//= require govuk/stick-at-top-when-scrolling
//= require govuk/stop-scrolling-at-footer
//= require moj
//= require modules/moj.cookie-message.js
//= require jquery-accessible-accordion-aria.js
//= require typeahead-aria.js
//= require jquery.jq-element-revealer.js
//= require_tree ./modules

(function() {
  'use strict';
  delete moj.Modules.devs;

  jQuery.fn.exists = function() {
    return this.length > 0;
  };

  /*! Tiny Pub/Sub - v0.7.0 - 2013-01-29
   * https://github.com/cowboy/jquery-tiny-pubsub
   * Copyright (c) 2013 "Cowboy" Ben Alman; Licensed MIT */
  var o = $({});
  $.subscribe = function() {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function() {
    o.off.apply(o, arguments);
  };

  $.publish = function() {
    o.trigger.apply(o, arguments);
  };

  // AGFS supplier number has a further level of
  // conditions when to show / hide
  $.subscribe('/provider/type/', function(e, obj) {
    var agfsIsChecked = $('#provider_roles_agfs').is(':checked');
    var $agfsSupplierInput = $('#js-agfs-supplier-number');
    if (agfsIsChecked) {
      if (obj.eventValue === 'firm') {
        $agfsSupplierInput.show();
        return;
      }
      $agfsSupplierInput.hide();
    }
  });

  $.subscribe('/scheme/type/agfs/', function() {
    if ($('#provider_provider_type_chamber').is(':checked')) {
      // the events conflict a little
      setTimeout(function() {
        $('#js-agfs-supplier-number').hide();
      }, 0);
    }
  });

  $.jqReveal({
    // options go here
  });

  $('#fixed-fees, #misc-fees, #disbursements, #expenses, #documents').on('cocoon:after-insert', function(e, insertedItem) {
    var $insertedItem = $(insertedItem);
    var insertedSelect = $insertedItem.find('select.typeahead');
    var typeaheadWrapper = $insertedItem.find('.js-typeahead');

    moj.Modules.Autocomplete.typeaheadKickoff(insertedSelect);
    moj.Modules.Autocomplete.typeaheadBindEvents(typeaheadWrapper);
    moj.Modules.MiscFeeFieldsDisplay.addMiscFeeChangeEvent(typeaheadWrapper);
  });

  //Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form, #claim-status').on('keypress', function(e) {
    if (e.keyCode === 13 && (e.target.type !== 'textarea' && e.target.type !== 'submit')) {
      return false;
    }
  });

  var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");

  GOVUK.stickAtTopWhenScrolling.init();

  moj.init();
}());