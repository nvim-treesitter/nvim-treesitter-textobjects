--- selecting @function.inner should look back when it's within @function.outer.
local function a()
  print('foo')
end -- call here to test

local function b()
  print('bar')
end
