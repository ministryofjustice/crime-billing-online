const { environment } = require('@rails/webpacker')
const ConcatPlugin = require('webpack-concat-plugin')



environment.plugins.append('ConcatPlugin', new ConcatPlugin({
  uglify: true,
  sourceMap: true,
  name: 'bundle',
  outputPath: 'js',
  fileName: 'application.bundle.js',
  filesToConcat: [
    './app/javascript/javascripts/vendor/polyfill.object.keys.js',
    'jquery',
    'jquery-ujs',
    'jquery.iframe-transport',
    './app/javascript/javascripts/vendor/jquery.remotipart.js',
    'cocoon/app/assets/javascripts/cocoon.js',
    'dropzone',
    './app/javascript/javascripts/vendor/polyfills/bind.js',
    'govuk_frontend_toolkit/javascripts/govuk/stick-at-top-when-scrolling.js',
    // 'govuk_frontend_toolkit/javascripts/govuk/stop-scrolling-at-footer.js',
    './app/javascript/javascripts/vendor/moj.js',
    './app/javascript/javascripts/vendor/modules/moj.cookie-message.js',
    'jquery-accessible-accordion-aria',
    './app/javascript/javascripts/vendor/typeahead-aria.js',
    './app/javascript/javascripts/vendor/jquery.jq-element-revealer.js',
    './app/javascript/javascripts/vendor/jquery.datatables.min.js',
    'jsrender',
    'jquery-highlight',
    'jquery-throttle-debounce',
    'accessible-autocomplete',
    'jquery-xpath/jquery.xpath.js',
    './app/javascript/javascripts/modules/Helpers.API.Core.js',
    './app/javascript/javascripts/modules/Helpers.API.Distance.js',
    './app/javascript/javascripts/modules/Helpers.API.Establishments.js',
    './app/javascript/javascripts/modules/Helpers.Autocomplete.js',
    './app/javascript/javascripts/modules/Helpers.DataTables.js',
    './app/javascript/javascripts/modules/Helpers.FormControls.js',
    './app/javascript/javascripts/modules/Modules.AddEditAdvocate.js',
    './app/javascript/javascripts/modules/Modules.AllocationDataTable.js',
    './app/javascript/javascripts/modules/Modules.AllocationFilterSubmit.js',
    './app/javascript/javascripts/modules/Modules.AllocationScheme.js',
    './app/javascript/javascripts/modules/Modules.AmountAssessed.js',
    './app/javascript/javascripts/modules/Modules.Autocomplete.js',
    './app/javascript/javascripts/modules/Modules.DataTables.js',
    './app/javascript/javascripts/modules/Modules.ExpensesDataTable.js',
    './app/javascript/javascripts/modules/Modules.HideErrorOnChange.js',
    './app/javascript/javascripts/modules/Modules.Messaging.js',
    './app/javascript/javascripts/modules/Modules.OffenceSearchInput.js',
    './app/javascript/javascripts/modules/Modules.OffenceSearchView.js',
    './app/javascript/javascripts/modules/Modules.OffenceSelectedView.js',
    './app/javascript/javascripts/modules/Modules.Providers.js',
    './app/javascript/javascripts/modules/Modules.SelectAll.js',
    './app/javascript/javascripts/modules/Modules.TableRowClick.js',
    './app/javascript/javascripts/modules/Plugin.jqDataTable.filter.js',
    './app/javascript/javascripts/modules/case_worker/Allocation.js',
    './app/javascript/javascripts/modules/case_worker/ReAllocation.js',
    './app/javascript/javascripts/modules/case_worker/admin/Modules.ManagementInformation.js',
    './app/javascript/javascripts/modules/case_worker/claims/DeterminationCalculator.js',
    './app/javascript/javascripts/modules/details.polyfill.js',
    './app/javascript/javascripts/modules/external_users/claims/BasicFeeDateCtrl.js',
    './app/javascript/javascripts/modules/external_users/claims/BlockHelpers.js',
    './app/javascript/javascripts/modules/external_users/claims/CaseTypeCtrl.js',
    './app/javascript/javascripts/modules/external_users/claims/ClaimIntentions.js',
    './app/javascript/javascripts/modules/external_users/claims/CocoonHelper.js',
    './app/javascript/javascripts/modules/external_users/claims/DisbursementsCtrl.js',
    './app/javascript/javascripts/modules/external_users/claims/Dropzone.js',
    './app/javascript/javascripts/modules/external_users/claims/DuplicateExpenseCtrl.js',
    './app/javascript/javascripts/modules/external_users/claims/FeeFieldsDisplay.js',
    './app/javascript/javascripts/modules/external_users/claims/FeePopulator.js',
    './app/javascript/javascripts/modules/external_users/claims/FeeSectionDisplay.js',
    './app/javascript/javascripts/modules/external_users/claims/InterimFeeFieldsDisplay.js',
    './app/javascript/javascripts/modules/external_users/claims/NewClaim.js',
    './app/javascript/javascripts/modules/external_users/claims/OffenceCtrl.js',
    './app/javascript/javascripts/modules/external_users/claims/SchemeFilter.js',
    './app/javascript/javascripts/modules/external_users/claims/SideBar.js',
    './app/javascript/javascripts/modules/external_users/claims/TransferDetailFieldsDisplay.js',
    './app/javascript/javascripts/modules/external_users/claims/TransferDetailsCtrl.js',
    './app/javascript/javascripts/modules/external_users/claims/fee_calculator/FeeCalculator.GraduatedPrice.js',
    './app/javascript/javascripts/modules/external_users/claims/fee_calculator/FeeCalculator.UnitPrice.js',
    './app/javascript/javascripts/modules/external_users/claims/fee_calculator/FeeCalculator.js',
    './app/javascript/javascripts/modules/show-hide-content.js',
    './app/javascript/javascripts/plugins/jquery.numbered.elements.js',
    './app/javascript/javascripts/application.js'
  ]
}))

module.exports = environment
