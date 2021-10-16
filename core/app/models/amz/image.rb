module Amz
    class Image < Amz::Asset
    include ActiveStorage::ImageStorage 
  
    end
end