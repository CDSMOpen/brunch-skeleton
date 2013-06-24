// ===============================================================================
//
//  Custom implementation of Twitter Bootstrap Typeahead plugin
//  http://twitter.github.com/bootstrap/javascript.html#typeahead
//
//  v1.0.1
//  Terry Rosen  -  @rerrify
//  Mike Moore - Added extraOptions array to default options. Add an array of Strings to add
//               some defined static options to the bottom of the menu when it shows. String match
//               on the text in itemSelected to work out which got hit.
//				 Added differentDockElement property to feed in an seperate option to the typeahead element
//				 So the drop down box positions itself around that instead of the input.
//				 Added styleClassProp which can be set to add different style classes to the list's li's
//
//  Requires jQuery 1.7+ and Twitter Bootstrap
//
!
function($) {

  "use strict"

  var Typeahead = function(element, options) {
      this.$element =     $(element)
      this.options =      $.extend({}, $.fn.typeahead.defaults, options)
      this.$menu =        $(this.options.menu).appendTo('body')      
      this.source =       this.options.source
      this.shown =        false
      this.matcher =      this.options.matcher      || this.matcher
      this.sorter =       this.options.sorter       || this.sorter
      this.highlighter =  this.options.highlighter  || this.highlighter
      this.select =       this.options.select       || this.select
      this.render =       this.options.render       || this.render  
      this.listen()
    }

  Typeahead.prototype = {

    constructor: Typeahead

    ,
    select: function() {
      var $selectedItem = this.$menu.find('.active')
      this.$element.val($selectedItem.text())
      this.options.itemSelected($selectedItem, $selectedItem.attr('data-value'), $selectedItem.text())
	  return this.lookup()
    }

    ,
    show: function() {
	
	  if( this.options.differentDockingElement == null ){
		  var pos = $.extend({}, this.$element.offset(), {
			height: this.$element[0].offsetHeight
		  })
	  }
	  else {
		  var pos = $.extend({}, this.options.differentDockingElement.offset(), {
			height: this.options.differentDockingElement[0].offsetHeight
		  })
	  }

      this.$menu.css({
        top: pos.top + pos.height,
        left: pos.left
      })

      var $extraOptions = $('<ul class="extraOptions"></ul>')
      var optionsArray = this.options.extraOptions
      if( optionsArray ){
        for ( var i=0; i<optionsArray.length; i++ )
            $extraOptions.append( $( '<li><a href="#">' + optionsArray[i] + '</a></li>' ) )
      }      
      this.$menu.append( $extraOptions )
      this.$menu.show()
      this.shown = true

      return this
    }

    ,
    hide: function() {
      this.$menu.hide()
      this.shown = false

      return this
    }

    ,
    lookup: function(event) {
      var _this = this
      var items
      var q

      this.query = this.$element.val()

      if (!this.query && this.persistantDropDown == false) {
        return this.shown ? this.hide() : this
      }

	  items = []
	  if( this.query && this.query != " " ){
		  items = $.grep(this.source, function(item) {
			var propVal = item[_this.options.matchProp]
			if (_this.matcher(propVal)) return item
		  })
	  }

      items = this.sorter(items)

      if (!items.length && this.persistantDropDown == false) {
		return this.shown ? this.hide() : this
      }

      return this.render(items.slice(0, this.options.items)).show()
    }

    ,
    matcher: function(val) {
      return ~val.toLowerCase().indexOf(this.query.toLowerCase())
    }

    ,
    sorter: function(items) {
      var _this = this
      var beginswith = []
      var caseSensitive = []
      var caseInsensitive = []
      var item

      while (item = items.shift()) {
        var propVal = item[_this.options.matchProp]
        if (!propVal.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(item)
        else if (~propVal.indexOf(this.query)) caseSensitive.push(item)
        else caseInsensitive.push(item)
      }

      return beginswith.concat(caseSensitive, caseInsensitive)
    }

    ,
    highlighter: function(item) {
      return item.replace(new RegExp('(' + this.query + ')', 'ig'), function($1, match) {
        return '<strong>' + match + '</strong>'
      })
    }

    ,
    render: function(items) {
      var _this = this

	  var styleClass = this.options.styleClassProp
      items = $(items).map(function(i, item) {
        i = $(_this.options.item)
		
        if (i) {
		  i.attr('data-value', item[_this.options.valueProp])
		  if( styleClass != "" ){
			i.addClass(item[styleClass])
		  }
          i.find('a').html(_this.highlighter(item[_this.options.matchProp]))
          return i[0]
        }
      })

      items.first().addClass('active')
      this.$menu.html(items)
      return this
    }

    ,
    next: function(event) {
      var active = this.$menu.find('.active').removeClass('active')
      var next = active.next()

      if (!next.length) {
        next = $(this.$menu.find('li')[0])
      }

      next.addClass('active')
    }

    ,
    prev: function(event) {
      var active = this.$menu.find('.active').removeClass('active')
      var prev = active.prev()

      if (!prev.length) {
        prev = this.$menu.find('li').last()
      }

      prev.addClass('active')
    }

    ,
    listen: function() {
      this.$element.on('blur', $.proxy(this.blur, this)).on('keypress', $.proxy(this.keypress, this)).on('keyup', $.proxy(this.keyup, this)).on('focus', $.proxy(this.lookup, this))

      if ($.browser.webkit || $.browser.msie) {
        this.$element.on('keydown', $.proxy(this.keypress, this))
      }

      this.$menu.on('click', $.proxy(this.click, this)).on('mouseenter', 'li', $.proxy(this.mouseenter, this))	  
    }

    ,
    keyup: function(e) {
      e.stopPropagation()
      e.preventDefault()

      switch (e.keyCode) {
      case 40:
        // down arrow
      case 38:
        // up arrow
        break

      case 9:
        // tab
      case 13:
        // enter
        if (!this.shown) return
        this.select()
        break

      case 27:
        // escape
        this.hide()
        break

      default:
        this.lookup()
      }

    }

    ,
    keypress: function(e) {
      e.stopPropagation()
      if (!this.shown) return

      switch (e.keyCode) {
      case 9:
        // tab
      case 13:
        // enter
      case 27:
        // escape
        e.preventDefault()
        break

      case 38:
        // up arrow
        e.preventDefault()
        this.prev()
        break

      case 40:
        // down arrow
        e.preventDefault()
        this.next()
        break
      }
    }

    ,
    blur: function(e) {
      var _this = this
      e.stopPropagation()
      e.preventDefault()
      setTimeout(function() {
        _this.hide()
      }, 150)
    }

    ,
    click: function(e) {
      e.stopPropagation()
      e.preventDefault()
      this.select()
    }

    ,
    mouseenter: function(e) {
      this.$menu.find('.active').removeClass('active')
      $(e.currentTarget).addClass('active')
    }

  }


  /* TYPEAHEAD PLUGIN DEFINITION
   * =========================== */

  $.fn.typeahead = function(option) {
    return this.each(function() {
      var $this = $(this)
      var data = $this.data('typeahead')
      var options = typeof option == 'object' && option
      if (!data) $this.data('typeahead', (data = new Typeahead(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.typeahead.defaults = {
    source: [],
    items: 8,
    menu: '<ul class="typeahead dropdown-menu"></ul>',
    item: '<li><a href="#"></a></li>',
    matchProp: 'name',
    sortProp: 'name',
    valueProp: 'id',
    itemSelected: function () { },
    extraOptions: [],
	persistantDropDown: false,
	differentDockingElement: null,
	styleClassProp: ""
  }

  $.fn.typeahead.Constructor = Typeahead


  /* TYPEAHEAD DATA-API
   * ================== */

  $(function() {
    $('body').on('focus.typeahead.data-api', '[data-provide="typeahead"]', function(e) {
      var $this = $(this)
      if ($this.data('typeahead')) return
      e.preventDefault()
      $this.typeahead($this.data())
    })
  })

}(window.jQuery)