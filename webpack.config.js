/* Webpack Starter Config File
 * Supports using 'require' to load:
 *  - .js, .coffee, .coffee.md, .litcoffee
 *    - compiled if necessary and exports are loaded
 *  - .css, .scss, .sass
 *    - compiled, autoprefixed, and added to document
 *  - .jpeg, .png, .gif
 *    - copied to dist folder, "require" returns URL reference 
 */

var webpack = require("webpack");
var path = require("path");

module.exports = {
    cache: true,
    entry: "./src/index.coffee",
    output: {
        path: path.join(__dirname, "dist"),
        publicPath: "",
        filename: "main.js"
    },
    module: {
        loaders: [
            // CSS/SASS
            { test: /\.css$/,     loader: "style!css!autoprefixer" },
            { test: /\.scss$/,    loader: "style!css!autoprefixer!sass" },
            { test: /\.sass$/,    loader: "style!css!autoprefixer!sass?indentedSyntax" },
            
            // CoffeeScript
            { test: /\.coffee$/,                 loader: "coffee" },
            { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee?literate" },
            
            // Images, fonts, etc.
            { test: /\.(png|jpe?g|gif)$/,    loader: "url?limit=1000" },
            { test: /\.(ttf|eot|svg|woff)(\?.+)?$/, loader: "file" }
        ]
    },
    plugins: []
};
