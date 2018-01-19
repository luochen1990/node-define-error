defineError = require('../lib/define-error')

MyError = defineError('MyError')

throw new MyError('a simple custom error')
