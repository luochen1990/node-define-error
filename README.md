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

File `rpc-error.js`:

```javascript
defineError = require('node-define-error')

RpcError = defineError('RpcError', ['from', 'api'])  //NOTE: define custom fields here as specification

fetch = (url) => Promise.reject(new Error('failed to fetch "' + url + '"'))

rpcCall = async () => {
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
rpcCall().catch((e) => {
    console.log(e.stack)
})

```

Error stack:

```text
RpcError:
  [from]: "client"
  [api]: "path/to/some/api"

  Caused By: Error: failed to fetch "http://path/to/some/api"
      at fetch (/the/very/very/long/path/to/rpc-error.js:5:33)

    at rpcCall (/the/very/very/long/path/to/rpc-error.js:16:15)
    at <anonymous>
    at runMicrotasksCallback (internal/process/next_tick.js:121:5)
    at _combinedTickCallback (internal/process/next_tick.js:131:7)
    at process._tickCallback (internal/process/next_tick.js:180:9)
    at Function.Module.runMain (module.js:678:11)
    at startup (bootstrap_node.js:187:16)
    at bootstrap_node.js:608:3
```

Deep Nested Example
-------------------

File `nested-error.js`:

```javascript
const defineError = require('node-define-error')

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
```

Error stack:

```text
MyAdvError:
  [f]: "f2"
  [msg]: "the outer custom error"

  Caused By: MyAdvError:
    [f]: "f1"
    [msg]: "the medium custom error"

    Caused By: Error: the inner custom error
        at f0 (/the/very/very/long/path/to/nested-error.js:6:11)

      at f1 (/the/very/very/long/path/to/nested-error.js:13:15)

    at f2 (/the/very/very/long/path/to/nested-error.js:21:15)
    at Object.<anonymous> (/the/very/very/long/path/to/nested-error.js:25:1)
    at Module._compile (module.js:635:30)
    at Object.Module._extensions..js (module.js:646:10)
    at Module.load (module.js:554:32)
    at tryModuleLoad (module.js:497:12)
    at Function.Module._load (module.js:489:3)
    at Function.Module.runMain (module.js:676:10)
    at startup (bootstrap_node.js:187:16)
    at bootstrap_node.js:608:3
```

Reference
---------

- [Tero's answer @stackoverflow](http://stackoverflow.com/questions/1382107/whats-a-good-way-to-extend-error-in-javascript/5251506#5251506)
- [Onur Yıldırım's answer @stackoverflow](https://stackoverflow.com/a/35881508/1608276)
- [customizing-stack-traces @v8-wiki](https://github.com/v8/v8/wiki/Stack-Trace-API#customizing-stack-traces)

