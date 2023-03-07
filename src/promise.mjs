export async function await_(promise, callback) {
    const value = await promise;
    return callback(value);
}

export async function awaitMany(promises, callback) {
    const values = await Promise.all(promises);
    return callback(values);
}
