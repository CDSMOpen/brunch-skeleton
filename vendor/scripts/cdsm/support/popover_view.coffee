# A base class for popup views

window.support ?= {}

class support.PopoverView extends support.View
	
	#TODO: Show on hover option
	
	positionDefaults:
		my: 'center center' # "top", "center", "bottom", "left", "right"
		at: 'center center' # "top", "center", "bottom", "left", "right"
		of: null
		nextTo: null
		offset: '0 0' # x, y
	
	initialize: (options) ->
		options = _.defaults options or {},
			toggle: true
			triggerEl: null
		
		super options
		
		if options.triggerEl
			@$triggerEl = if (options.triggerEl instanceof $) then options.triggerEl else $ options.triggerEl
		
		if options.position
			@position = _.extend @positionDefaults, options.position
			
			# Parse the position and offset strings
			@position.my = @parsePositionString @position.my
			@position.at = @parsePositionString @position.at
			@position.offset = @parseOffsetString @position.offset
			
			# Store a reference to the DOM element we need to associate the popup with
			if @position.of
				@position.$of = if (@position.of instanceof $) then @position.of else $ @position.of
			
			# Store a reference to the DOM element we need to base our insertion on
			if @position.nextTo
				@position.$nextTo = if (@position.nextTo instanceof $) then @position.nextTo else $ @position.nextTo
		
		@addListeners()
	
	# Overidden method that positions the popup everytime the element is set
	setElement: (element, delegate) ->
		# If we already have an element, remove it
		@$el.remove() if @$el
		
		# Let the super do it's thing
		super element, delegate
		
		# Add a popover class to the element
		@$el.addClass 'popover'
		
		# Add handle position
		@$el.addClass(@position.my.join('-')) if @position and @position.my
		
		# HACK: set z-index higher than the current 1000 so not covered by file package items
		# @$el.css
		#	'z-index': 1050
		
		# If we have a DOM element to associate the popup with
		if @position and @position.$nextTo
			@position.$nextTo.after @el
			
			@updatePosition()
		else
			$('body').append @el
		
		this
	
	parsePositionString: (str) ->
		rtn = str.split ' '
		
		# Convert single value positions
		if rtn.length is 1
			switch rtn[0]
				when 'center'
					rtn.push 'top'
				when 'left'
					rtn.push 'center'
				when 'right'
					rtn.push 'center'
				when 'top'
					rtn.unshift 'center'
				when 'bottom'
					rtn.unshift 'center'
		
		rtn
	
	parseOffsetString: (str) ->
		rtn = str.split ' '
		
		# Convert single value offsets
		if rtn.length is 1
			rtn.push rtn[0]
		
		rtn = _.map rtn, (num) ->
			parseFloat num
		
		rtn =
			x: rtn[0]
			y: rtn[1]
	
	getSizeOf: ($el) ->
		rtn =
			width: $el.width()
			height: $el.height()
	
	getPositionOf: ($el) ->
		pos = $el.offset()
		size = @getSizeOf $el
		
		# Adjust the top position based on scroll position
		pos.top = pos.top - $(window).scrollTop()
		
		# Calculate other values of use
		rtn =
			right: pos.left + size.width
			bottom: pos.top + size.height
			xCenter: pos.left + (size.width/2)
			yCenter: pos.top + (size.height/2)
		
		rtn = _.extend pos, size, rtn
	
	#TODO: If right aligned then take values from right side of browser - this could potentially prevent us having
	# to rely on window resize event to update
	getTargetPosition: ->
		targetX = 0
		targetY = 0
		
		if @position.$of
			# Get size and position of anchor
			anchorPos = @getPositionOf @position.$of
			
			# Get size of the popover
			popSize = @getSizeOf @$el
			
			# Calculate the left value
			targetX = switch @position.at[0]
				when 'center'
					anchorPos.xCenter
				else
					anchorPos[@position.at[0]]
			
			# Calculate the top value
			targetY = switch @position.at[1]
				when 'center'
					anchorPos.yCenter
				else
					anchorPos[@position.at[1]]
			
			# Adjust calculations based on relative placement
			targetX = switch @position.my[0]
				when 'right'
					targetX - popSize.width
				when 'center'
					targetX - (popSize.width/2)
				else
					targetX
			
			targetY = switch @position.my[1]
				when 'bottom'
					targetY - popSize.height
				when 'center'
					targetY - (popSize.height/2)
				else
					targetY
		
		rtn =
			x: targetX + @position.offset.x
			y: targetY + @position.offset.y
	
	updatePosition: =>
		# Position the popover based on the anchor, if provided
		if @position and @position.$of
			# Get target position
			targetPos = @getTargetPosition()
			
			# Apply to the element
			@$el.css
				left: targetPos.x
				top: targetPos.y
	
	addListeners: ->
		# Listen for window resize and scroll event
		$(window).on 'resize.popover', @onResize
		$(window).on 'scroll.popover', @updatePosition
		
		# Listen for click outside to trigger close
		$(document).on 'click.popover', @onDocumentClick
	
	removeListeners: ->
		$(window).off 'resize.popover', @onResize
		$(window).off 'scroll.popover', @updatePosition
		$(document).off 'click.popover', @onDocumentClick
	
	dispose: ->
		@$triggerEl = null
		
		# Remove event listeners
		@removeListeners()
		
		super()
	
	# Method for triggering a close event and kicking off the clean up  
	close: (data=null) =>
		@trigger 'close',
			target: this
			data: data
		@leave() if @options.autoClose
	
	onResize: (e) => @updatePosition()
	
	# Called when a click event is triggered for the entire document. Will close the
	# popout if the click originates from outside of the popout or if the click was
	# on on the @$triggerEl and toggle is true.
	onDocumentClick: (e) =>
		# return if e.isDefaultPrevented()
		
		$popover = $(e.target).closest '.popover'
		clickWasInPopover = $popover.length and $popover[0] is @el
		clickWasOnTargetEl = @$triggerEl and @$triggerEl[0] is e.target
		
		# If the click wasn't inside this popover or the target el then close
		# the popover unless toggle is true.
		@close() if not clickWasInPopover and (not clickWasOnTargetEl or @options.toggle)
		
		true
