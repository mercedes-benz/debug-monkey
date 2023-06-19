local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "debug-monkey"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          { host = typedefs.host { default = "host-gateway" }},
          { port = typedefs.port { default = 9966 } },
          {
            path_replacements = {
              type = "array",
              required = true,
              elements = {
                type = "record",
                required = true,
                fields = {
                  { container_path = {type = "string", required = true }},
                  { host_path = {type = "string", required = true }},
                }
              },
              } },
        },
        entity_checks = {
        },
      },
    },
  },
}

return schema
