## cdn fu
cdn fu is a fun domain specific language for deployment of assets to content
deliver network.  There are 4 pluggable steps in the chain:

1. Preprocessing
2. Listing
3. Minification
4. Uploading

## Installation

    ruby script/plugin install git://github.com/jubos/cdn_fu.git 


## Example
For example, you can first run a Sass/Sprockets/AssetPacker during
preprocessing, then minify all of the resulting .js and .css assets, and
finally upload to a third party CDN.


