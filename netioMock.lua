----- NETIO MOCK METHOD section-----
-- TODO: cover full NETIO Lua references: https://wiki.netio-products.com/index.php?title=NETIO_Lua_Reference
-- delay
local clock = os.clock
function delay(n, callback)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
  callback();
end

-- log
function log(message)
  print(message)
end

-- cgiGet
cgiGetResult = { response = "" };
function cgiGet(data)
  local result = {buffer = cgiGetResult.response, result = 0}
  data.callback(result)
end

-- devices
devices = { system = {} }
function devices.system.SetOut(data)
  print(string.format ("Device %i set state %i", data.output, (data.value and 1 or 0)))
end

-- json (installed by luarocks)
json = require ("externals/dkjson")

-----End of NETIO MOCK METHOD-----