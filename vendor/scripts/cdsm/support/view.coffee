# This is the base View that should be extended instead of
# Backbone.Voiew.
# 
# Based on Chapter 5 of 'Backbone In Rails'. **CompositeView** is designed to automatically
# manage clean up of it's children and event bindings when it is removed.
# 
# Use **bindTo()** and **unbindFrom()** to add and remove event bindings rather than binding
# directly to the target.
# 
# Use **renderChild()** to add a child view to a parent CompositeView.
# 
# Call the **leave()** method to remove event bindings and call **leave()** on all child
# views.

window.support ?= {}

class support.View extends Backbone.View
	
	# The pixel with and height values as set from size()
	_width: undefined
	_height: undefined
	
	initialize: (options) ->
		super options
		
		# Set a unique identifier for the view
		# @cid = new Date().getTime()
		@cid = _.uniqueId()
		
		@children = []
		@bindings = []
	
	# Size is for setting and persisting the size of a view. Pass in the *width*
	# and *height* to set the *min-width* and *min-height* of the element. Override
	# this when you need to use the values to set the size of any child elements.
	# The width and height are persisted as the *_width* and *_height* values on
	# the the instance.
	size: (width, height) ->
		@_width = width
		@_height = height
		@$el.css
			'min-width': if @_width then "#{@_width}px" else undefined
			'min-height': if @_height then "#{@_height}px" else undefined
	
	# Function to clean up this view, it's event bindings and any subviews that
	# may belong to it.
	leave: (removeFromDOM=true) ->
		@off()
		@remove() if removeFromDOM
		@_leaveChildren()
		@_removeFromParent()
		@unbindAll()
		@dispose()
	
	# Called automatically from the **leave()** method when the view is being removed.
	# Override this for any special cases where a pointer or binding needs to be disposed
	# of when the view is removed.
	dispose: ->
	
	# Method to add an event binding to an object and store the reference so it can be easily
	# cleaned up later. If a view binds to a model, you should **always** use **bindTo()**
	# insted of **model.on()**.
	# 
	# *source* - The object to listen to
	# *event* - The type of event to listen for
	# *callback* - The method to call when the event fires
	bindTo: (source, event, callback) ->
		source.on event, callback#, this
		bindings = @bindings
		_.each event.split(' '), (e) =>
			bindings.push
				source: source
				event: e
				callback: callback
	
	# Bind a function to a target event once. This will automatically clean up
	# and remove the handler when the event is triggered so you don't have to.
	bindOnce: (source, event, callback) ->
		proxy = =>
			@unbindFrom source, event, proxy
			callback.apply null, arguments
		@bindTo source, event, proxy
	
	# Remove a binding added with **bindTo()**
	# 
	# *source* - The object to stop unbind from
	# *event* - The type of event to remove
	# *callback* - The callback of the binding to remove
	unbindFrom: (source, event, callback) ->
		binding = _.find @bindings, (o, i) -> true if o.event is event and o.callback is callback
		if binding
			@bindings.splice _.indexOf(@bindings, binding), 1
			binding.source.off binding.event, binding.callback#, this
	
	# Method for unbinding all events that the view has added via **bindTo()**. Called from
	# **leave()** to automatically clean up event bindings when a view is removed.
	unbindAll: ->
		_.each @bindings, (binding) => binding.source.off binding.event, binding.callback#, this
		@bindings = []
	
	# Check if a binding has been added with **bindTo()**
	# 
	# *source* - The object that has been bound to
	# *event* - The type of event
	# *callback* - The callback of the binding
	hasBinding: (source, event, callback) ->
		binding = _.find @bindings, (o, i) -> true if o.source is source and o.event is event and o.callback is callback
	
	# Renders the view passed in and stores it as a child of this view
	# 
	# *view* - The view to render
	renderChild: (view) ->
		view.render()
		@children.push view
		view.parent = this
		view
	
	# Adds the **view** passed in to the **container** passed in
	# renderChildInto: (view, container) -> $(container).html @renderChild(view).el
	
	# Adds the view passed in to this el
	# appendChild: (view) -> @$el.append @renderChild(view).el
	
	# Removes a reference to the child without removing it from the DOM
	# removeChild: (view) -> view.leave false if view
	
	# Internal method. Calls leave() on each of the children of this view
	_leaveChildren: ->
		return if not @children
		
		# Because children are removed from the array when leave() is called (via _removeFromParent > _removeChild)
		# we need to iterate over the array backward (with a reversed clone)
		_.each @children.slice(0).reverse(), (view) ->
			view.leave() if view.leave
	
	# Internal method. Removes this view from it's parent view
	_removeFromParent: -> @parent._removeChild this if @parent
	
	# Internal method. Removes a sub view
	# 
	# *view* - The view to remove
	_removeChild: (view) ->
		i = _.indexOf @children, view
		if i > -1
			@children.splice i, 1
			delete view.parent
	
	# Shortcut method for replacing the current element of a view. Use it where
	# you are calling setElement() from within render, and need to render
	# the same view multiple times.
	replaceElement: (el) ->
		
		#TODO: If it's a string wrap it with $
		
		$el = $ el
		@$el.replaceWith $el[0]
		@setElement $el[0]

