defineError = require('../lib/define-error')

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

