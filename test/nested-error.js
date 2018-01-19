const defineError = require('../lib/define-error')

const MyAdvError = defineError('MyAdvError', ['f', 'msg'])

function f0() {
    throw new Error('the inner custom error')
}

function f1() {
    try {
        return f0()
    } catch (e) {
        throw new MyAdvError({ f: 'f1', msg: 'the medium custom error' }, e)
    }
}

function f2() {
    try {
        return f1()
    } catch (e) {
        throw new MyAdvError({ f: 'f2', msg: 'the outer custom error' }, e)
    }
}

f2()
