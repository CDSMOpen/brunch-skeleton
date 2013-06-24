# This is the base Collection that should be extended instead of
# Backbone.Collection.

window.support ?= {}

class support.Collection extends Backbone.Collection
	
	# Override of default fetch to trigger fetch start and end events
	fetch: (options) ->
		options = if options then _.clone(options) else {}
		
		success = options.success
		options.success = (model, resp) => 
			@trigger 'fetch:end', 
				type: 'fetch:end'
			if success then success model, resp
		
		error = options.error
		options.error = (originalModel, resp, options) => 
			@trigger 'fetch:end', 
				type: 'fetch:end'
			if error then error originalModel, resp, options
		
		@trigger 'fetch:start', 
			type: 'fetch:start'
		
		super options
	
	# Update the collection rather than resetting it.
	# This method is added so that we can easily update the properties
	# of models in a collection without resetting the entire collection
	# unless it's needed.
	# If the models passed in match up with the models in the collection
	# then each one will be updated with the new info. If they don't
	# then the whole collection will be reset.
	update: (models) =>
		
		# Are there the same number of models?
		if @length and models.length and @length is models.length
			
			# Are all their ID's the same?
			allMatch = true
			for a in models
				if not @find((b) -> a.id and b.id and a.id is b.id)
					allMatch = false
					break
			
			# If they are then parse the new model object and set the results
			if allMatch
				for o in models
					model = @get o.id
					model.set model.parse(o)
			else
				@reset models
		else
			@reset models
