[![Unix build](https://img.shields.io/github/actions/workflow/status/Kong/kong-plugin/test.yml?branch=master&label=Test&logo=linux)](https://github.com/Kong/kong-plugin/actions/workflows/test.yml)
[![Luacheck](https://github.com/Kong/kong-plugin/workflows/Lint/badge.svg)](https://github.com/Kong/kong-plugin/actions/workflows/lint.yml)

# Kong debug plugin

This is a community-provided plugin for debugging Kong using EmmyLua.

For using this plugin, you need to install the [EmmyLua plugin]() for your IDE.

## IntelliJ run configuration

To debug Kong using IntelliJ, you need to create a new `Emmy Debugger(NEW)` run configuration:

- as connection, choose `Debugger connect IDE`
- as host, either choose `0.0.0.0` so that the debugger running inside the container can connect to your IDE
- leave port as `9966`

## VSCode run configuration

Debugger launch.json:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "emmylua_new",
      "request": "launch",
      "name": "EmmyLua New Debug",
      "host": "0.0.0.0",
      "port": 9966,
      "ext": [".lua", ".lua.txt", ".lua.bytes"],
      "ideConnectDebugger": false
    }
  ]
}
```

## Setup Kong for debugging

To setup Kong for debugging, you need to add the following to your `kong.conf`:

```yaml
plugins:
  - name: debug-monkey
    config:
      ## host to connect to, defaults to `host-gateway` (see docker container configuration below)
      # host: "host-gateway"
      ## port to connect to, defaults to `9966`
      # port: 9966

      ## As the debugger is running inside the container, you need to map the source code. Provided as a list of
      ## `container_path` and `host_path` pairs. The `container_path` is the path inside the container, the `host_path`
      ## is the path on the host machine. Required.
      ##
      ## Be aware that the `container_path` is a Lua pattern, so you need to escape special characters like `.` or `-`.
      ##
      ## The order is maintained. Be sure to add the most specific paths first, and the most generic paths last: for
      ## example, provide the path to the plugin first and then the path to the Kong source code.
      path_replacements:
        ## provided as an example, you do not necessarily need to add the debug plugin, as you'll probably not jump into
        ## it's source code anyway
        - container_path: '/usr/local/share/lua/5.1/kong/plugins/debug%-monkey/'
          host_path: '/home/<your-username>/src/github.com/mercedes-benz/debug-monkey/kong/plugins/debug-monkey/'
        # do not forget to map the Kong source code, as you'll frequently jump into it's source code
        - container_path: '/usr/local/share/lua/5.1/kong/'
          host_path: '/home/<your-username>/src/github.com/Kong/kong/kong/'
```

# Setup Docker for debugging

To setup Docker for debugging, you need to add the following to your `docker-compose.yml` (extend your existing kong service):

```yaml
services:
  kong:
    ## as the emmy lua debugger is linked against glibc, we need to use the ubuntu image
    image: kong:3.3.0-ubuntu
    ## we need to map the host gateway to the container, so that the debugger can connect to the IDE (`host-gateway`
    ## is a magic DNS name that resolves to the host gateway)
    extra_hosts:
      - host-gateway:host-gateway
    ## we need to add the `debug-monkey` plugin to the list of plugins
    environment:
      - KONG_PLUGINS=bundled,debug-monkey
    ## map the debugger plugin and the emmy lua library into the container
    volumes:
      - /home/<your-username>/src/github.com/mercedes-benz/debug-monkey/kong/plugins/debug-monkey:/usr/local/share/lua/5.1/kong/plugins/debug-monkey
      - <path-to-library>:/usr/local/emmy
```

## Use debugger

This is it -- start the debugger in your IDE and start/reload Kong. You should see the debugger connecting to your IDE.
Set a breakpoint, and you're ready to go! If the debugger does not connect, check the logs of the Kong container:

```bash
docker compose logs kong --tail 100 -f |& grep -E '|emmy|debug-monkey'
```

If you step into code but seem stuck at the same line, you likely stepped into code that has not been mapped.

# Provider Information

Please visit [Provider Information](https://github.com/mercedes-benz/foss/blob/master/PROVIDER_INFORMATION.md) for information on the provider Mercedes-Benz Tech Innovation GmbH.
