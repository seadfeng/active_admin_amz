# frozen_string_literal: true

# Take a signed permanent reference for a blob and turn it into an expiring service URL for download.
# Note: These URLs are publicly accessible. If you need to enforce access protection beyond the
# security-through-obscurity factor of the signed blob references, you'll need to implement your own
# authenticated redirection controller.
class ActiveStorage::BlobsController < ActiveStorage::BaseController
    include ActiveStorage::SetBlob
  
    def show
        expires_in 1.year, public: true  
        send_data   @blob.download,
                    type: @blob.content_type || DEFAULT_SEND_FILE_TYPE,
                    disposition: 'inline'
    end
end