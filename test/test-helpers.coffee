# This file will be automatically required when using `brunch test` command.
module.exports =
	chai: require 'chai'
	expect: require('chai').expect
	should: require('chai').should()
	sinon: require 'sinon'
	sinonChai: require('chai').use require('sinon-chai')
	Backbone: require 'backbone'