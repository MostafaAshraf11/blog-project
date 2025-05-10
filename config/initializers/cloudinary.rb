require 'cloudinary'

Cloudinary.config_from_url("cloudinary://555114447294219:JqV25j1fKLKRXGn2-PX55YoCYX4@dgfukkkda")
Cloudinary.config do |config|
  config.secure = true
end