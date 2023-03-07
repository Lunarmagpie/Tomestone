import { promises as fs } from "node:fs";

import {
    Error,
    Ok,
} from "./gleam.mjs";

import {
    Eacces,
    Eexist,
    Eisdir,
    Emfile,
    Enoent,
    Enotempty,
    Enotdir,
    Epipe,
    Unknown,
} from "./tomestone/fs.mjs";

// TODO (help wanted): Support all system errors
function handleError(err) {
    let errort = Unknown;
    if (err.code === "EACCES") {
        errort = Eacces
    }
    if (err.rcode === "EEXIST") {
        errort = Eexist
    }
    if (err.code === "EISDIR") {
        errort = Eisdir
    }
    if (err.code === "EMFILE") {
        errort = Emfile
    }
    if (err.code === "ENOENT") {
        errort = Enoent
    }
    if (err.code === "ENOTDIR") {
        errort = Enotdir
    }
    if (err.code === "ENOTEMPTY") {
        errort = Enotempty
    }
    if (err.code === "EPIPE") {
        errort = Epipe
    }

    return new Error(new errort())
}

export async function readFile(path) {
    try {
        const data = await fs.readFile(path, 'utf-8');
        return new Ok(data);
    } catch (err) {
        return callback(handleError(err));
    }
}

export async function readFileBits(path) {
    try {
        const data = await fs.readFile(path);
        return new Ok(data);
    } catch (err) {
        return handleError(err);
    }
}
