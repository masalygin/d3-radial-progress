extend = (a, b) ->
	for own key, value of b
		a[key] = value
	a


class @D3RadialProgress
	defaults:
		fontSize: 15
		size: 300
		value: 0
		min: 0
		max: 100
		thick: 10


	constructor: (options) ->
		extend @, @defaults
		extend @, options
		@_layout()
		@_background()
		@_arc()
		@_label()


	_layout: ->
		@node = d3.select @node
		@svg = @node.append 'svg'
		@enter = @svg
		.attr 'class', 'radial-progress'
		.attr 'width', @size
		.attr 'height', @size

	_background: ->
		arc = d3.svg.arc()
		.startAngle 0
		.endAngle Math.PI * 2
		.outerRadius @size / 2
		.innerRadius @size / 2 - @thick
		@enter
		.append 'path'
		.attr 'class', 'bg-arc'
		.attr 'transform', "translate(#{@size / 2}, #{@size / 2})"
		.attr 'd', arc


	_arc: ->
		@arc = d3.svg.arc()
		.startAngle 0
		.endAngle 0
		.outerRadius @size / 2
		.innerRadius @size / 2 - @thick
		@path = @enter
		.append 'path'
		.attr 'class', 'arc'
		.attr 'transform', "translate(#{@size / 2}, #{@size / 2})"
		.attr 'd', @arc


	_label: ->
		@label = @enter
		.append 'text'
		.attr 'class', 'label'
		.attr 'y', @size / 2 + @fontSize / 3
		.attr 'x', @size / 2
		.attr 'width', @size
		.text @value
		.style 'font-size', @fontSize + 'px'


	set: (value = 100, duration = 1000) ->
		self = @
		if value > @max or value < @min
			value = value %% @max
			if value is 0
				value = @max
		@label
		.datum value
		.transition()
		.duration duration
		.tween 'text', (a) ->
			i = d3.interpolate self.value, a
			(t) ->
				self.value = i(t)
				@textContent = Math.round(self.value) + '%'
		@path
		.datum value / 100 * 2 * Math.PI
		.transition()
		.duration duration
		.attrTween 'd', ->
			->
				angle = self.value / 100 * 2 * Math.PI
				self.arc.endAngle(angle)()