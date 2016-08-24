/**
 * Created by diver on 15.08.16.
 */
'use strict';

const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    context: path.join(__dirname, '/frontend/src'),

    entry: {
        //client: "./client",
        app: "./app.jsx"
    },

    output: {
        path: path.join(__dirname, "/public"),
        filename: "[name].[chunkhash:6].js",
        publicPath: "/"
    },

    devtool: null,

    module: {
        loaders: [
            {
                test: /\.jsx?$/,
                exclude: /(node_modules|bower_components)/,
                loader: 'babel',
                query: {
                    presets: [ 'es2015', 'react' ],
                    plugins: [ 'transform-runtime' ]
                }
            },
            { test: /\.jade$/, loader: 'jade' },
            { test: /\.css$/,  loader: 'style-loader!css-loader' },
            { test: /.*\/fonts\/.*\.(png|jpg|svg|ttf|eot|woff|woff2)$/, loader: 'file?name=/fonts/[sha1:hash:base36:10].[ext]' },
            { test: /.*\/images\/.*\.(png|jpg|svg|ico)$/, loader: 'file?name=/images/[sha1:hash:base36:10].[ext]' }
        ]
    },

    plugins: [
        new webpack.DefinePlugin({
            NODE_ENV: 'production',
            LANG: "'ru'"
        }),

        new webpack.NoErrorsPlugin(),

        //new HtmlWebpackPlugin({
        //    title: 'Chat (production mode)',
        //    template: './index.ejs',
        //    filename: 'index.html',
        //    favicon: 'assets/images/favicon.ico',
        //    chunks: [ 'client' ]
        //}),

        new HtmlWebpackPlugin({
            title: 'Login',
            template: './index.ejs',
            filename: 'index.html',
            favicon: 'assets/images/favicon.ico',
            chunks: [ 'login' ]
        }),

        new webpack.optimize.UglifyJsPlugin({
            compress: {
                drop_console: true,
                warnings:     false,
                unsafe:       true
            }
        })
    ]
};
