# A model that keeps track of whether it's current state has been synchronised with the server or not

window.support ?= {}

class support.SyncModel extends support.Model
	
	_savedState: null
	
	_dirty: null
	
	initialize: ->
		super
		
		@on 'sync', => @_savedState = @toJSON()
	
	sync: (method, model, options) ->
		options = if options then _.clone(options) else {}
		
		success = options.success
		options.success = (resp, status, xhr) ->
			if success then success resp, status, xhr
			model.trigger 'sync', model, resp, options
		
		error = options.error
		options.error = (xhr, status, thrown) ->
			if error then error model, xhr, options
			model.trigger 'error', model, xhr, options
		
		xhr = Backbone.sync.call this, method, model, options
		model.trigger 'request', model, xhr, options
		xhr
	
	isDirty: (ignore=[]) ->
		return @_dirty if @_dirty isnt null
		
		current = _.omit @toJSON(), ignore
		saved = _.omit @_savedState, ignore
		
		not _.isEqual current, saved
	
	markDirty: -> @_dirty = true
	
	markClean: -> @_dirty = false
