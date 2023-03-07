import {
    Error,
    Ok,
} from "./gleam.mjs";


let Runtime = { "Node": "Node", "Deno": "Deno" }

function getRuntime() {
    if (typeof process !== 'undefined') {
        return Runtime.Node
    }

    if (typeof Deno !== 'undefined') {
        return Runtime.Deno
    }
    throw new Error("Unknown platform. This code must be run with Node or Deno.")
}


export function getEnv(name) {
    let runtime = getRuntime()
    let env;
    if (runtime === Runtime.Node) {
        // We must be in Node
        env = process.env[name]
    }
    if (runtime === Runtime.Deno) {
        // We must be in Deno
        env = Deno.env.get(name);
    }

    if (env !== undefined) {
        return new Ok(env);
    } else {
        return new Error(env);
    }
}
