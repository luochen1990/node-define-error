defineError = require('../lib/define-error')

MyError = defineError('MyError')

throw new MyError({msg: 'a simple custom error'})
