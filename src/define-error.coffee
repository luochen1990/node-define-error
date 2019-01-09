indent = (text) ->
	text.split('\n').map((l) -> '  ' + l).join('\n')

###
# Case 1: showInfo : (fields : List String) -> ((info : Object) -> String)
# Case 2: showInfo : (msgMaker : (info : Object) -> String) -> ((info : Object) -> String)
###
showInfo = (msgMaker) ->
	if typeof msgMaker is 'function'
		msgMaker
	else if msgMaker instanceof Array
		(info) ->
			'\n' + msgMaker.map((k) ->
				v = info[k]
				"  [#{k}]: #{JSON.stringify(info[k])}"
			).join('\n')
	else
		((s) -> if typeof s is 'object' then JSON.stringify(s) else s)

#simpleFormatter = (error, structuredStackTrace) ->
#	log.info 'call simpleFormatter', error.info.x
#	return JSON.stringify(structuredStackTrace[0].getFileName())
#Error.prepareStackTrace = simpleFormatter

headStackTrace = (e) ->
	s = e.stack
	i = s.indexOf('\n    at ')
	j = s.indexOf('\n', i+8) # 8 is length of the above string
	return s[..j]

###
# Usage 1: defineError(errorName : String, fields : List String)
# Usage 2: defineError(errorName : String, msgMaker : (info : Object) -> String)
###
defineError = (errorName, msgMaker) ->
	msg = showInfo(msgMaker)
	`
	function CustomError(info, cause) {
		if (Error.captureStackTrace) {
			Error.captureStackTrace(this, CustomError);
		} else {
			Object.defineProperty(this, 'stack', {
				enumerable: false,
				writable: false,
				value: (new Error(message)).stack
			});
		}

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
	# test
	{log} = require ('coffee-mate')
	MyError = defineError('MyError', () -> "my error occurs")
	try
		throw new MyError()
	catch e
		log -> e
		log -> e.name
		log -> e.constructor.name
		log -> e.constructor.name == e.name
		log -> e.message == "my error occurs"
		log -> typeof e == "object"
		log -> typeof MyError == "function"
		log -> Object.getPrototypeOf(e) == Error.prototype
		log -> Object.getPrototypeOf(e) == MyError.prototype
		log -> e instanceof Error
		log -> e instanceof MyError
		log -> typeof e.toString is 'function' and e.toString().indexOf(e.name) >= 0
		log -> e.stack.indexOf(e.name) >= 0
		log -> e.stack.indexOf(e.message) >= 0

	# nested error demo
	MyAdvError = defineError('MyAdvError', ['f', 'msg'])
	#f0 = -> throw new MyAdvError({f: 'f0', msg: 'the inner custom error'})
	f0 = -> throw new Error('the inner custom error')
	f1 = -> try f0() catch e then throw new MyAdvError({f: 'f1', msg: 'the medium custom error'}, e)
	f2 = -> try f1() catch e then throw new MyAdvError({f: 'f2', msg: 'the outer custom error'}, e)
	f2()

