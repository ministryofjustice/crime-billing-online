
# class to create specialized text field wrapped in all the GDS gubbins
class AdpTextField

  attr_reader :form, :method, :options

  include ExternalUsers::ClaimsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper


  # instantiate an AdpTextField object
  # * form: the instance of AdpFormBuilder that this is called from
  # * method: the method on the object that the form is wrapping that this input field is for
  # * options:
  #   * label: label to be provided for the input field
  #   * hint_text: Hint text displayed underneath the label
  #   * input_classes: Css classes on the input
  #   * input_type: Input type will default to `text`
  #   * errors: An ErrorPresenter for the form object, or the form object itself
  #   * value: the value to display (if no specified, the value is taken by calling method on the form object)

  def initialize(form, method, options)
    @form = form
    @method = method
    @options = options

    generate_ids
    extract_options
  end


  # the methods output_buffer= and output_buffer are required by the content_tag
  # methods, called from the validation_error_message in ExternalUsers::ClaimsHelper
  #
  def output_buffer=(value)
    @errors = value
  end

  def output_buffer
    @errors
  end

  def has_errors?
    return false if @errors.nil?
    @errors.errors_for?(@error_key.to_sym)
  end

  def to_html
    result = div_start
    result += anchor
    result += label
    result += hint
    result += label_close
    result += input_field
    result += error_message
    result += div_close
    result.html_safe
  end

  private

  def generate_ids
    @form_field_id = generate_form_field_id
    @form_field_name = generate_form_field_name
    @anchor_id = generate_anchor_id
  end

  def extract_options
    @errors = options[:errors]
    @input_classes = options[:input_classes] || ''
    @input_type = options[:input_type] || 'text'
    @error_key = options[:error_key] || @anchor_id
    @value = (options[:value] || form.object.__send__(method)).to_s
    setup_input_type
  end

  def setup_input_type
    @input_is_number = false
    @input_is_currency = (@input_type == 'currency')
    @input_type_string = @input_type

    if @input_type == 'currency' || @input_type == 'number'
      @input_is_number = true
      @input_type_string = 'number'
      @input_min = options[:input_min] || '0'
      @input_max = options[:input_max] || '99999'
    end
  end

  def generate_form_field_id
    # @form.object_name either returns a symbol for top level fields (e.g. :claim), or
    # a string like "claim[defendants_attributes][0]" for cocoon nested objects
    if @form.object_name.is_a?(Symbol)
      "#{@form.object_name}_#{@method}"
    else
      # translates e.g. claim[defendants_attributes][0]_last_name to claim_defendants_attributes_0_last_name
      @form.object_name.to_s.tr('[', '_').tr(']', '_').gsub('__', '_') + @method.to_s
    end
  end

  def generate_form_field_name
    # @form.object_name either returns a symbol for top level fields (e.g. :claim), or
    # a string like "claim[defendants_attributes][0]" for cocoon nested objects
    "#{@form.object_name}[#{@method}]"
  end

  def generate_anchor_id
    # translates e.g. claim_defendants_attributes_0_last_name to defendant_1_last_name
    anchor = @form_field_id.sub(/^claim_/, '').gsub('s_attributes', '')
    parts = anchor.split('_')
    incremented_anchor_parts = []
    parts.each do |part|
      incremented_anchor_parts << if part =~ /^[0-9]{1,2}$/
                                    (part.to_i + 1).to_s
                                  else
                                    part
                                  end
    end
    incremented_anchor_parts.join('_')
  end

  def div_start
    result = %|<div class="form-group #{@method}_wrapper|
    result += %| field_with_errors| if has_errors?
    result += %|">|
    result
  end

  def anchor
    %|<a id="#{@anchor_id}"></a>|
  end

  def currency
    %|<span class="currency-indicator">&pound;</span>|
  end

  def label
    %|<label class="form-label" for="#{@form_field_id}">#{@options[:label]}|
  end

  def label_close
    %|</label>|
  end

  def error_message
    has_errors? ? validation_error_message(@errors, @error_key) : ''
  end

  def hint
    if @options[:hint_text]
      %|<span class="form-hint">#{@options[:hint_text]}</span>|
    else
      ''
    end
  end

  def input_field
    result = %||
    if @input_is_currency
      result += %|<span class="currency-indicator">&pound;</span>|
    end
    result += %|<input class="form-control #{@input_classes}" type="#{@input_type_string}" name="#{@form_field_name}" id="#{@form_field_id}" |
    result += %|value="#{strip_tags(@value)}" | unless @form.object.__send__(@method).nil?
    if @input_is_number
      result += %|min="#{@input_min}" |
      result += %|max="#{@input_max}" |
    end
    result += %|/>|
    result
  end

  def div_close
    '</div>'
  end
end
