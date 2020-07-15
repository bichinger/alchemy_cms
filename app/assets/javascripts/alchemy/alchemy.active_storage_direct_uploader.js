Alchemy.ActiveStorageDirectUploader = function (settings) {

  settings.fileInput.addEventListener('change', (event) => {
    Array.from(settings.fileInput.files).forEach(file => uploadFile(file))
    // you might clear the selected files from the input
    settings.fileInput.value = null
  })

  const uploadFile = (file) => {
    // your form needs the file_field direct_upload: true, which
    //  provides data-direct-upload-url
    const url = settings.fileInput.dataset.directUploadUrl
    const upload = new ActiveStorage.DirectUpload(file, url)

    upload.create((error, blob) => {
      console.log('create: ', error, blob);
      if (error) {

        // Handle the error
        console.error('File upload failed: ', error);

      } else {
        console.log('adding hidden field . . . ', settings);

        let $fileUploadForm = $(settings.fileUploadForm);

        $.post(
          $fileUploadForm.attr('action'),
          {
            authenticity_token: $fileUploadForm.find('input[name=authenticity_token]').val(),
            active_storage_file: {
              file: blob.signed_id,
            }
          }
        );
      }
    })

  }
}
