/**
 * Created by diver on 15.08.16.
 */
'use strict';

const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const path              = require('path');

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
                loaders: ['babel'],
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

        new HtmlWebpackPlugin({
            title: 'Chat',
            template: './index.ejs',
            filename: '../backend/views/index.erb',
            favicon: 'assets/images/favicon.ico',
            chunks: [ 'app' ]
        }),

        new webpack.optimize.UglifyJsPlugin({
            compress: {
                drop_console: true,
                warnings:     false,
                unsafe:       true
            },
            output: {
                comments:     false
            }
        })
    ]
};
