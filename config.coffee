exports.config =
	# See http://brunch.readthedocs.org/en/latest/config.html for documentation.
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^vendor/
				'test/javascripts/test.js': /^test[\\/](?!vendor)/
				'test/javascripts/test-vendor.js': /^test[\\/](?=vendor)/
			order:
				# Files in `vendor` directories are compiled before other files
				# even if they aren't specified in order.before.
				before: [
					'vendor/scripts/jquery-1.10.1.js'
					'vendor/scripts/underscore-1.4.4.js'
					'vendor/scripts/backbone-0.9.2.js'

					'vendor/scripts/cdsm/support/view.coffee'
				]
		
		stylesheets:
			joinTo:
				'stylesheets/app.css': /^(app|vendor)/
				'test/stylesheets/test.css': /^test/
		
		templates:
			joinTo: 'javascripts/app.js'
		
	server:
		port: 3333