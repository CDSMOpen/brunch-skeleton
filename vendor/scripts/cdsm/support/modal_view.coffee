# A base class for modal views

window.support ?= {}

class support.ModalView extends support.View
	
	modalTemplate: _.template '<div id="<%= cid %>" class="js-modal-wrapper"><div class="js-modal-bg"></div><div class="js-modal-content"></div></div>'
	
	modalEvents:
		'click .js-modal-close': 'onCloseClick'
	
	modalDefaults:
		domEL: 'body'
		draggable: false
		showCloseButton: true
		
	constructor: (options) ->
		
		if defaults = @modalDefaults
			options = _.extend {}, defaults, options
		
		@events = _.extend {}, @modalEvents, @events
		
		super options
	
	initialize: (options) ->
		super options
		
		# Store a reference to the DOM element we need to attach the view to (defaults to the <body>)
		@$domEL = null
		if options?.domEL
			@$domEL = if (options.domEL instanceof $) then options.domEL else $ options.domEL
		else
			@$domEL = $ 'body'
		# @domEL = @$domEL[0]
		
		# Create the modal wrapper
		@$modalWrapper = $ @modalTemplate
			cid: @cid
		
		# Append to the DOM element
		@$domEL.append @$modalWrapper
		
		$(window).on "resize.#{@cid}", @onWindowResize
	
	# Overidden method that updates the contents of the wrapper everytime the element is set
	setElement: (element, delegate) ->
		super element, delegate
		$modalContent = $('.js-modal-content', @$modalWrapper)
		
		$modalContent.html @el
		
		# Add close button if required
		if @options.showCloseButton
			$close = $ @make 'a',
				href: '#'
				class: 'js-modal-close'
			$modalContent.append $close
			$close.on 'click', @onCloseClick
		
		@center()
		
		# Make draggable if required
		@makeDraggable() if @options.draggable and $.fn.draggable
		
		this
	
	
	render: -> @center()
	
	center: ->
		$modalContent = $ '.js-modal-content', @$modalWrapper
		$window = $ window
		
		$modalContent.css
			top: ($window.height()/2) - ($modalContent.height()/2)
			left: ($window.width()/2) - ($modalContent.width()/2)
		
		this
	
	makeDraggable: ->
		$modalContent = $ '.js-modal-content', @$modalWrapper
		options = @options.draggable
		
		if options.handle?
			$handle = $ options.handle, $modalContent
			$handle.draggable('destroy') if $handle.data('draggable') or $handle.data('ui-draggable') # jQuery ui pre and post 1.9 check
			
			options = _.extend {}, options,
				handle: $handle
		
		$modalContent.draggable options
	
	# Overridden method so that the wrapper can be removed from the DOM
	leave: (removeFromDOM=true) ->
		$(window).off "resize.#{@cid}", @onWindowResize
		
		$modalContent = $ '.js-modal-content', @$modalWrapper
		
		if @options.draggable and ($modalContent.data('draggable') or $modalContent.data('ui-draggable')) # jQuery ui pre and post 1.9 check
			$modalContent.draggable 'destroy'
		
		super removeFromDOM
		
		@$modalWrapper.remove() if removeFromDOM
	
	cancel: ->
	
	# Method for triggering a close event and kicking off the clean up  
	close: (leave=true) ->
		@trigger 'close',
			target: this
		@leave() if leave
	
	onCloseClick: (e) =>
		e.preventDefault()
		@cancel()
		@close()
	
	onWindowResize: (e) => @center()
