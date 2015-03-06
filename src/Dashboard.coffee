# Main dashboard class
window.Dashboard = {} unless Dashboard?

Dashboard =
	widgets: {}
	templates: {}

class Dashboard.Client extends Backbone.Model
	initialize: (@config)->
		@connect()
		@view = new Dashboard.View model: @

	url: (config)->
		return config.url

	connect: ->
		@_ws = new WebStorage _.result @, 'url', @config
		@_bindWs()

	_bindWs: ->
		@_ws.onopen = =>
			@_ws.onmessage = (data)=>
				@parse data

		@_ws.onerror = =>
			@_reconnect()

	_reconnect: ->
		console.log 'Connection error'

		setTimeout =>
			@connect()
		, 2000

	parse: (data)->
		if typeof data is 'string'
			data = JSON.parse data


class Dashboard.View extends Backbone.View
	initialize: ->
