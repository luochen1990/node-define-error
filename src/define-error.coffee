indent = (text) ->
	text.split('\n').map((l) -> '  ' + l).join('\n')

showInfo = (fields) ->
	if fields?
		(info) ->
			'\n' + fields.map((k) ->
				v = info[k]
				"  [#{k}]: #{JSON.stringify(info[k])}"
			).join('\n')
	else
		((s) -> s)

#simpleFormatter = (error, structuredStackTrace) ->
#	log.info 'call simpleFormatter', error.info.x
#	return JSON.stringify(structuredStackTrace[0].getFileName())
#Error.prepareStackTrace = simpleFormatter

headStackTrace = (e) ->
	s = e.stack
	i = s.indexOf('\n    at ')
	j = s.indexOf('\n', i+8) # 8 is length of the above string
	return s[..j]

defineError = (errorName, fields) ->
	msg = showInfo(fields)
	`
	function CustomError(info, cause) {
		Error.captureStackTrace(this, CustomError);
		Object.defineProperties(this, {
			'name': {enumerable: true, writable: false, value: errorName},
			'message': {enumerable: false, get: function(){ //the parts with stacktrace is not enumerable
				r = msg(info) + (cause == null ? '' : '\n\n' + indent('Caused By: ' + headStackTrace(cause)))
				return r
			}},
			'info': {enumerable: true, writable: false, value: info},
			'cause': {enumerable: false, writable: false, value: cause},
		});
	}
	Object.setPrototypeOf(CustomError.prototype, Error.prototype);
	`
	return CustomError

module.exports = defineError

if module.parent is null
	MyAdvError = defineError('MyAdvError', ['f', 'msg'])
	#f0 = -> throw new MyAdvError({f: 'f0', msg: 'the inner custom error'})
	f0 = -> throw new Error('the inner custom error')
	f1 = -> try f0() catch e then throw new MyAdvError({f: 'f1', msg: 'the medium custom error'}, e)
	f2 = -> try f1() catch e then throw new MyAdvError({f: 'f2', msg: 'the outer custom error'}, e)
	f2()

