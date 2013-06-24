# **EventAggrigator** is a class for aggregating events through a single location
# to simplify and decouple modular applications.
# 
# Backbone.Events is mixed in so you use it the same way as Backbone via **on**,
# **off** and **trigger**.
# 
# The suggested use is to setup an **EventAggregator** instance in the global
# **window.App.eventAggregator** namespace then subscribe to and fire application
# level events through it.
# 
# You should **not** direct all events through it, only events that require separate
# views to talk to each other, or events that require the Application controller
# to respond.
# 
# Usage:
# 	
# 	window.App.on 'navigate', @navigateHome
# 	
# 	window.App.trigger 'navigate',
# 		moduleId: 'module1'
# 		pageIndex: 8

window.support ?= {}

class support.EventAggregator
	
	constructor: -> _.extend this, Backbone.Events
