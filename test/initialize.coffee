# Automatically require all tests (files that end with '_test')
for module in window.require.list() when /_test$/.test module
	require module
