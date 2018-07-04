module DropzoneHelper
  def drag_and_drop_file(selector, file)
    id = SecureRandom.uuid
    page.execute_script <<-JS
      tempFileInput = window.$('<input/>').attr(
        {id: 'temp-file-input-#{id}', name: 'temp-file-input', type: 'file'}
      ).appendTo('body');
    JS

    attach_file("temp-file-input-#{id}", file)

    page.execute_script('fileList = [tempFileInput.get(0).files[0]];')

    page.execute_script <<-JS
      e = jQuery.Event('drop', { dataTransfer : { files : fileList } });
      $('.#{selector}')[0].dropzone.listeners[0].events.drop(e);
      $('#temp-file-input-#{id}').remove();
    JS
  end
end

World(DropzoneHelper)
