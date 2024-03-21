--- === my.module ===
---
--- Module description.
---
--- A second line of description.

local foo = require("foo")

local mod = {}

--- my.module.funcWithReturn(a, b) -> boolean
--- Function
--- Function description.
---
--- Parameters:
---  * a - a parameter.
---  * b - another parameter.
---
--- Returns:
---  * `true` if some condition is met.
function mod.func(a, b)
    return true
end

--- my.module.var
--- Variable
--- Variable description.
mod.var = true

--- my.module:methodWithoutReturn(a, [b])
--- Method
--- Method description.
---
--- Parameters:
---  * a - a parameter.
---  * b - an optional parameter.
---
--- Returns:
---  * Nothing.
function mod:method(a, b)
end

--- my.module:methodWithReturn(a) -> string
--- Method
--- Method description.
---
--- Parameters:
---  * a - a `string` parameter.
---
--- Returns:
---  * The same string.
function mod:method(a)
    return a
end

--- my.module.field <table: string>
--- Field
--- A `table` containing `string`s.
function mod.lazy.value:field()
    return {"one", "two", "three"}
end

--- my.module.badMethod()
--- Method
--- Should fail due to missing ':'.
---
--- Parameters:
---  * None
---
--- Returns:
---  * Nothing

return mod
