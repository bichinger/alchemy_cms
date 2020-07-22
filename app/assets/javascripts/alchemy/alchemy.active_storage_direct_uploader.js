Alchemy.ActiveStorageDirectUploader = function (settings) {

  settings.fileInput.addEventListener('change', (event) => {
    Array.from(settings.fileInput.files).forEach(file => uploadFile(file))
    // clear the selected files from the input
    settings.fileInput.value = null
  })

  const uploadFile = (file) => {
    // your form needs the file_field direct_upload: true, which
    // provides data-direct-upload-url
    const url = settings.fileInput.dataset.directUploadUrl
    const upload = new ActiveStorage.DirectUpload(file, url)

    upload.create((error, blob) => {
      if (error) {
        console.error('File upload failed: ', error);
        Alchemy.growl('File upload failed: ' + error );
      } else {

        let $fileUploadForm = $(settings.fileUploadForm);

        $.post(
          $fileUploadForm.attr('action'),
          {
            authenticity_token: $fileUploadForm.find('input[name=authenticity_token]').val(),
            active_storage_file: {
              file: blob.signed_id,
              name: blob.filename,
            }
          }
        )
          .done(function () {
            if (settings.in_dialog) {
              $.get(settings.redirect_url, null, null, 'script');
            }
            else {
              Turbolinks.visit(settings.redirect_url);
            }
          })
          .fail(function ( jqXHR, textStatus, errorThrown ) {
            let errMsg = textStatus +': '+ jqXHR.responseText +' | '+ errorThrown;
            console.error('File upload failed: ', errMsg);
            Alchemy.growl(errMsg);
          })
          // .always(function () {
          // });
      }
    })

  }
}
