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
      console.log('create: ', error, blob);
      if (error) {

        // TODO: Handle the error
        console.error('File upload failed: ', error);

      } else {
        console.log('adding hidden field . . . ', settings, blob);

        let $fileUploadForm = $(settings.fileUploadForm);

        let request = $.post(
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
            console.log('upload successfully done . . . redirecting');

            if (settings.in_dialog) {
              $.get(settings.redirect_url, null, null, 'script');
            }
            else {
              Turbolinks.visit(settings.redirect_url);
            }

          })
          .fail(function () {

            // TODO: Handle the error
            console.error('File upload failed: ', error);

          })
          // .always(function () {
          // });
      }
    })

  }
}
