# This is the base Model that should be extended instead of
# Backbone.Model..

window.support ?= {}

class support.Model extends Backbone.Model
	
	# Overriden to trigger **saving** and **save** events before and after
	# saving.
	save: (attributes, options) ->
		oldSuccess = options?.success
		@trigger 'save:start', this
		options = _.extend {}, options,
			success: (model, response, options) =>
				@trigger 'save:success', this
				oldSuccess? model, response, options
		super attributes, options
	
	# Reset the model back to it's default values
	reset: -> @clear(silent:true).set @defaults
	
	# Overriden to add a convention where all properties starting with
	# an _ will be deleted from toJSON. This is a simple rule that is
	# applied to all models so **private** properties wont be synced but
	# can still be used for event bindings etc.
	toJSON: ->
		json = super
		for key, value of json
			delete json[key] if key.charAt(0) is '_'
		json
