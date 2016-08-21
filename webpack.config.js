/**
 * Created by diver on 15.08.16.
 */
'use strict';

const webpack           = require('webpack');
const path              = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const NODE_ENV        = process.env.NODE_ENV || 'development';


module.exports = {
    context: __dirname + '/frontend/src',

    entry: {
        client: "./client"
    },

    output: {
        path: __dirname + "/public",
        filename: "[name].js",
        publicPath: "/"
    },

    watchOptions: {
        aggregateTimeout: 100
    },

    devtool: 'eval', // 'cheap-inline-module-source-map',

    devServer: {
        contentBase: __dirname + '/public',
        quiet: false,
        historyApiFallback: true,
    },

    module: {
        loaders: [
            {
                test: /\.jsx?$/,
                exclude: /(node_modules|bower_components)/,
                loaders: ['react-hot', 'babel'],
            },
            { test: /\.css$/,  loader: 'style-loader!css-loader' },
            { test: /.*\/fonts\/.*\.(png|jpg|svg|ttf|eot|woff|woff2)$/, loader: 'file?name=/fonts/[name].[ext]' },
            { test: /.*\/images\/.*\.(png|jpg|svg|ico)$/, loader: 'file?name=/images/[name].[ext]' },
        ]
    },

    plugins: [
        new webpack.NoErrorsPlugin(),
        new webpack.DefinePlugin({
            NODE_ENV: JSON.stringify(NODE_ENV),
            LANG: "'ru'"
        }),
        new HtmlWebpackPlugin({
            title:    'Development mode',
            template: './index.html',
            filename: 'index.html',
            favicon:  'assets/images/favicon.ico'
        })
    ]
};

