# This is an alternate base Collection that can be extended instead of
# support.Collection for lazy loading.

window.support ?= {}

class support.LazyCollection extends support.Collection
	
	initialize: (models, options) ->
		super models, options
		
		# The number of items per page
		@_count = 50
		
		# The current page
		@_page = 1
		
		# The total number of pages
		@_numPages = null
	
	# Override of default fetch to trigger a couple of custom events
	fetch: (options) ->
		options = if options then _.clone(options) else {}
		
		# Prepare url params
		data = 
			page: @_page
			count: @_count
		
		# Combine with existing data, the existing data taking priority
		options.data = _.extend {}, data, options.data
		
		super options
	
	parse: (resp, xhr) ->
		# If the response is empty then we make
		# an assumption about the number of pages
		if resp and resp.length < 1
			@setNumPages @getPage() - 1
		
		return super resp, xhr
	
	reset: (models, options) ->
		# Reset page vars
		@_page = 1
		@_numPages = null
		
		super models, options
	
	getCount: -> @_count
	
	setCount: (value, reset=true) ->
		@_count = value
		
		# Reset the collection
		@reset() if reset
	
	getPage: -> @_page
	
	setPage: (value) -> @_page = value
	
	getNumPages: -> @_numPages
	
	setNumPages: (value) ->
		@_numPages = value
		
		# Correct the current page if not valid
		if @getPage() > value
			@setPage value
	
	allLoaded: ->
		rtn = if @getNumPages() and @getPage() is @getNumPages() then true else false
	
	prevPage: ->
		if @_page > 1
			@_page -= 1
	
	nextPage: ->
		if !@_numPages or @_page < @_numPages
			@_page += 1