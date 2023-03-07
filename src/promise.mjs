import {
    toList
} from "./gleam.mjs"


export async function await_(promise, callback) {
    const value = await promise;
    return callback(value);
}

export async function gather(promises, callback) {
    const values = await Promise.all(promises);
    return callback(toList(values));
}

export async function resolve(value) {
    return Promise.resolve(value)
}

export async function sleep(time, callback) {
    await new Promise(value => setTimeout(value, time));
    return callback()
}
