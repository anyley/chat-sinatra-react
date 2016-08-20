var path = require('path');

module.exports = function (config) {
    config.set({
        basePath:   'frontend/',
        frameworks: ['jasmine'],
        files:      [
            'test/**/*.js'
        ],

        preprocessors: {
            // add webpack as preprocessor
            'src/**/*.js':  ['webpack', 'sourcemap'],
            'test/**/*.js': ['webpack', 'sourcemap']
        },

        webpack: { //kind of a copy of your webpack config
            devtool: 'eval',
            module: {
                loaders: [
                    {
                        test: /\.jsx?$/,
                        exclude: /(node_modules|bower_components)/,
                        loader: 'babel',
                        query: {
                            presets: [ 'es2015', 'react', 'airbnb' ],
                            plugins: [ 'transform-runtime' ]
                        }
                    },
                    { test: /\.css$/,  loader: 'style-loader!css-loader' },
                    { test: /\.(png|jpg|svg|ttf|eot|woff|woff2)$/, loader: 'file' },
                    {
                        test: /\.json$/,
                        loader: 'json',
                    },
                ]
            },
            externals: {
                'react/addons': true,
                'react/lib/ExecutionEnvironment': true,
                'react/lib/ReactContext': true
            }
        },

        webpackServer: {
            noInfo: true
        },

        plugins: [
            'karma-webpack',
            'karma-jasmine',
            'karma-sourcemap-loader',
            'karma-phantomjs-launcher'
        ],

        babelPreprocessor: {
            options: {
                presets: ["es2015", "react"]
            }
        },

        reporters:         ['progress'],
        port:              9876,
        colors:            true,
        logLevel:          config.LOG_INFO,
        autoWatch:         true,
        browsers:          ['PhantomJS'],
        singleRun:         true
    })
};