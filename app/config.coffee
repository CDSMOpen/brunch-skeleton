# This is the application config, use it as an Object hash and get
# it with require:
# 
# Config = require 'config'
# title = Config.title
# alert "Config.title is '#{title}'"

module.exports =
	
	IoC:
		
		key: undefined

		# TestClass:
		# 
		# 	# The require path identifier for the constructor
		# 	type: 'name/space/of/TestClass'
		# 
		# 	# The instances lifestyle, either 'singleton' or 'transient'
		# 	lifestyle: 'singleton'
		# 
		# 	# Object to be passed into the constructor of the class, this
		# 	# is most useful with backbone models where options are passed
		# 	# in like this.
		# 	# 
		# 	# It would be nice to do this as an Array but I haven't worked
		# 	# out a way to do that yet.
		# 	args:
		# 		key: 'value'
		# 
		# 	# Properties applied to the instance after construction
		# 	'properties':
		# 		'property': 'value'
		
#----------------------------------------------------------------------------------------------------
# Default Settings
#----------------------------------------------------------------------------------------------------
	
	# These settings are tokenizable (but they don't have to be) for use in the rest of
	# the config. They can be used by specifying the namespace to the value. The string..
	# 
	# 	"${content.course}"
	# 
	# ..would be replace with the value from..
	# 
	# 	defaultSettings.content.course
	# 
	# This is designed to easily allow a product specific config to be applied and merged
	# over the default settings in here so they can be overriden on a product by product
	# basis instead of specifying the entire config again.
	