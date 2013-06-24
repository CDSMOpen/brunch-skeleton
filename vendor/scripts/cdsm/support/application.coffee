# **ApplicationController** is a top level controller class for Backbone
# applications.
# 
# It handles the basics like displaying and switching top level views.
# 
# This is deliberately kept very thin and generic.

window.support ?= {}

class support.Application
	
	# Pass in the JQ DOM element to attach the application to, this will
	# default to the body if not specified.
	constructor: (@$el=$('body')) ->
		
		@currentView = null
	
	# Display the view passed in while cleaning up the existing one
	showView: (view) ->
		@currentView?.leave()
		@currentView = view
		@$el.append @currentView.render().el
