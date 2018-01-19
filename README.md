Node Define Error
=================

Define pretty printed, nested custom errors easily.

Features
--------

- define custom error easily
- define custom fields for your error
- pretty printed error message
- nested error support
- brief stack trace for nested error

Install
-------

```
npm install node-define-error
```

Simple Usage
------------

```
defineError = require('node-define-error')

MyError = defineError('MyError')

throw new MyError('a simple custom error')
```

Advanced Usage
--------------

```
defineError = require('node-define-error')

RpcError = defineError('RpcError', ['from', 'api'])  //NOTE: define custom fields here as specification

async rpcCall = () => {
    try {
        const response = await fetch('http://path/to/some/api')
        const result = JSON.parse(response)
        if (result.success !== true) {
            throw new RpcError({from: 'server', 'api': 'path/to/some/api'})
        }
        return result
    } catch (err) {
        throw new RpcError({from: 'client', 'api': 'path/to/some/api'}, err)  //NOTE: pass on an error as a cause of this error, this is optional
    }
}
```

Reference
---------

[Tero's answer @stackoverflow](http://stackoverflow.com/questions/1382107/whats-a-good-way-to-extend-error-in-javascript/5251506#5251506)
[Onur Yıldırım's answer @stackoverflow](https://stackoverflow.com/a/35881508/1608276)
[customizing-stack-traces @v8-wiki](https://github.com/v8/v8/wiki/Stack-Trace-API#customizing-stack-traces)

