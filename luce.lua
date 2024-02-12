--
-- luce
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
-- Noah: I hope just leaving this here is enough. Please don't sue me, thanks.

--[[

    luce v0.1.0
    Target: CraftOS using Lua 5.2

]]

local luce = { _version = "0.1.0" }

local pairs, ipairs = pairs, ipairs
local type, assert, unpack = type, assert, table.unpack
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2 or math.atan
local math_sqrt = math.sqrt
local math_abs = math.abs

local noop = function() end

local identity = function(x)
	return x
end

local patternescape = function(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

local absindex = function(len, i)
	return i < 0 and (len + i + 1) or i
end

local iscallable = function(x)
	if type(x) == "function" then
		return true
	end
	local mt = getmetatable(x)
	return mt and mt.__call ~= nil
end

local getiter = function(x)
	if luce.isarray(x) then
		return ipairs
	elseif type(x) == "table" then
		return pairs
	end
	error("expected table, got " .. type(x), 3)
end

local iteratee = function(x)
	if x == nil then
		return identity
	end
	if iscallable(x) then
		return x
	end
	if type(x) == "table" then
		return function(z)
			for k, v in pairs(x) do
				if z[k] ~= v then
					return false
				end
			end
			return true
		end
	end
	return function(z)
		return z[x]
	end
end

-- math functions

function luce.rerange(v, a, b, c, d)
	if a == b then
		return c
	end
	local result = c + (d - c) * ((v - a) / (b - a))
	result = result < c and c or (result > d and d or result)
	return result
end

function luce.mapvalue(value, start1, stop1, start2, stop2)
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1))
end

function luce.approx(a, b, precision)
	return math.abs(math.abs(a) - math.abs(b)) < precision
end

function luce.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function luce.lerp(a, b, amount)
	return a + (b - a) * luce.clamp(amount, 0, 1)
end

function luce.slerp(a, b, amount)
	local t = luce.clamp(amount, 0, 1)
	local m = t * t * (3 - 2 * t)
	return a + (b - a) * m
end

function luce.distance(x1, y1, x2, y2, squared)
	local s = (x1 - x2) ^ 2 + (y1 - y2) ^ 2
	return squared and s or math_sqrt(s)
end

function luce.round(x, increment)
	if increment then
		return luce.round(x / increment) * increment
	end
	return x >= 0 and math_floor(x + 0.5) or math_ceil(x - 0.5)
end

function luce.sign(x)
	return x < 0 and -1 or 1
end

function luce.angle(x1, y1, x2, y2)
	return math_atan2(y2 - y1, x2 - x1)
end

-- table functions

function luce.all(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	for _, v in iter(t) do
		if not fn(v) then
			return false
		end
	end
	return true
end

function luce.any(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	for _, v in iter(t) do
		if fn(v) then
			return true
		end
	end
	return false
end

function luce.isarray(x)
	return type(x) == "table" and x[1] ~= nil and x[#x] ~= nil
end

function luce.checksize(t)
	local len = #t
	local truesize = luce.count(t)
	if len ~= truesize then
		return false, truesize, len
	else
		return true, len
	end
end

function luce.push(t, ...)
	local n = select("#", ...)
	for i = 1, n do
		t[#t + 1] = select(i, ...)
	end
	return ...
end

function luce.pop(t)
	if luce.isarray(t) then
		local x = t[#t]
		t[#t] = nil
		return x
	end
	return nil
end

function luce.remove(t, x)
	local iter = getiter(t)
	for i, v in iter(t) do
		if v == x then
			if luce.isarray(t) then
				table.remove(t, i)
				break
			else
				t[i] = nil
				break
			end
		end
	end
	return x
end

function luce.removeall(t, should_remove_fn)
	local n = #t
	local j = 1

	for i = 1, n do
		if should_remove_fn(t[i], i, j) then
			t[i] = nil
		else
			-- Move i's kept value to j's position, if it's not already there.
			if i ~= j then
				t[j] = t[i]
				t[i] = nil
			end
			j = j + 1 -- Increment position of where we'll place the next kept value.
		end
	end

	return t
end

function luce.removeswap(t, should_remove_fn)
	local n = #t
	local i = 1
	while i <= n do
		local value = t[i]
		if should_remove_fn(value) then
			t[i] = t[n]
			t[n] = nil
			n = n - 1
		else
			i = i + 1
		end
	end
end

function luce.clear(t)
	local iter = getiter(t)
	for k in iter(t) do
		t[k] = nil
	end
	-- maybe launch gc?
	return t
end

function luce.find(t, value)
	local iter = getiter(t)
	for k, v in iter(t) do
		if v == value then
			return k
		end
	end
	return nil
end

function luce.match(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	for k, v in iter(t) do
		if fn(v) then
			return v, k
		end
	end
	return nil
end

function luce.each(t, fn, ...)
	local iter = getiter(t)
	if type(fn) == "string" then
		for _, v in iter(t) do
			v[fn](v, ...)
		end
	else
		for _, v in iter(t) do
			fn(v, ...)
		end
	end
	return t
end

function luce.eachi(t, fn, ...)
	local iter = getiter(t)
	if type(fn) == "string" then
		for _, v in iter(t) do
			v[fn](v, ...)
		end
	else
		for i, v in iter(t) do
			fn(v, i, ...)
		end
	end
	return t
end

function luce.map(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	for k, v in iter(t) do
		rtn[k] = fn(v, k)
	end
	return rtn
end

function luce.filter(t, fn, retainkeys)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	if retainkeys then
		for k, v in iter(t) do
			if fn(v) then
				rtn[k] = v
			end
		end
	else
		for _, v in iter(t) do
			if fn(v) then
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function luce.reject(t, fn, retainkeys)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	if retainkeys then
		for k, v in iter(t) do
			if not fn(v) then
				rtn[k] = v
			end
		end
	else
		for _, v in iter(t) do
			if not fn(v) then
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function luce.unique(t)
	local rtn = {}
	for k in pairs(luce.invert(t)) do
		rtn[#rtn + 1] = k
	end
	return rtn
end

function luce.pick(t, ...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local k = select(i, ...)
		rtn[k] = t[k]
	end
	return rtn
end

function luce.reduce(t, fn, first)
	local started = first ~= nil
	local acc = first
	local iter = getiter(t)
	for _, v in iter(t) do
		if started then
			acc = fn(acc, v)
		else
			acc = v
			started = true
		end
	end
	assert(started, "reduce of an empty table with no first value")
	return acc
end

function luce.extend(t, ...)
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if x then
			for k, v in pairs(x) do
				t[k] = v
			end
		end
	end
	return t
end

function luce.merge(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		local iter = getiter(t)
		for k, v in iter(t) do
			rtn[k] = v
		end
	end
	return rtn
end

function luce.concat(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		if t ~= nil then
			local iter = getiter(t)
			for _, v in iter(t) do
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

local chain_mt = {}
chain_mt.__index = luce.map(luce.filter(luce, iscallable, true), function(fn)
	return function(self, ...)
		self._value = fn(self._value, ...)
		return self
	end
end)
chain_mt.__index.result = function(x)
	return x._value
end

function luce.chain(value)
	return setmetatable({ _value = value }, chain_mt)
end

function luce.count(t, fn)
	local count = 0
	local iter = getiter(t)
	if fn then
		fn = iteratee(fn)
		for _, v in iter(t) do
			if fn(v) then
				count = count + 1
			end
		end
	else
		-- if luce.isarray(t) then
		--     return #t
		-- end
		for _ in iter(t) do
			count = count + 1
		end
	end
	return count
end

function luce.depth(t, currentDepth)
	currentDepth = currentDepth or 0
	if type(t) == "table" then
		local maxDepth = currentDepth
		for _, v in pairs(t) do
			local depth = luce.depth(v, currentDepth + 1)
			if depth > maxDepth then
				maxDepth = depth
			end
		end
		return maxDepth
	else
		return currentDepth
	end
end

function luce.first(t, n)
	if not n then
		return t[1]
	end
	return luce.slice(t, 1, n)
end

function luce.last(t, n)
	if not n then
		return t[luce.count(t)]
	end
	return luce.slice(t, -n, -1)
end

function luce.max(t)
	local max = -math.huge
	local iter = getiter(t)
	for _, v in iter(t) do
		if v > max then
			max = v
		end
	end
	return max
end

function luce.min(t)
	local min = math.huge
	local iter = getiter(t)
	for _, v in iter(t) do
		if v < min then
			min = v
		end
	end
	return min
end

function luce.keys(t)
	local rtn = {}
	local iter = getiter(t)
	for k in iter(t) do
		rtn[#rtn + 1] = k
	end
	return rtn
end

function luce.clone(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[k] = v
	end
	return rtn
end

function luce.deepclone(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[luce.deepclone(orig_key, copies)] = luce.deepclone(orig_value, copies)
			end
			setmetatable(copy, luce.deepclone(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function luce.slice(t, i, j)
	i = i and absindex(#t, i) or 1
	j = j and absindex(#t, j) or #t
	local rtn = {}
	for x = i < 1 and 1 or i, j > #t and #t or j do
		rtn[#rtn + 1] = t[x]
	end
	return rtn
end

function luce.invert(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[v] = k
	end
	return rtn
end

function luce.array(...)
	local t = {}
	for x in ... do
		t[#t + 1] = x
	end
	return t
end

function luce.shuffle(t)
	local rtn = {}
	for i = 1, #t do
		local r = math.random(i)
		if r ~= i then
			rtn[i] = rtn[r]
		end
		rtn[r] = t[i]
	end
	return rtn
end

function luce.sort(t, comp)
	local rtn = luce.clone(t)
	if comp then
		if type(comp) == "string" then
			table.sort(rtn, function(a, b)
				return a[comp] < b[comp]
			end)
		else
			table.sort(rtn, comp)
		end
	else
		table.sort(rtn)
	end
	return rtn
end

-- high level functions

-- might want to remove because computing speed is reduced anyway and memory limits of servers
local memoize_fnkey = {}
local memoize_nil = {}

function luce.memoize(fn)
	local cache = {}
	return function(...)
		local c = cache
		for i = 1, select("#", ...) do
			local a = select(i, ...) or memoize_nil
			c[a] = c[a] or {}
			c = c[a]
		end
		c[memoize_fnkey] = c[memoize_fnkey] or { fn(...) }
		return unpack(c[memoize_fnkey])
	end
end

function luce.once(fn, ...)
	local f = luce.fn(fn, ...)
	local done = false
	return function(...)
		if done then
			return
		end
		done = true
		return f(...)
	end
end

local lambda_cache = {}

function luce.lambda(str)
	if not lambda_cache[str] then
		local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
		assert(args and body, "bad string lambda")
		local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
		lambda_cache[str] = luce.dostring(s)
	end
	return lambda_cache[str]
end

function luce.l(str)
	luce.lambda(str)
end

function luce.combine(...)
	local n = select("#", ...)
	if n == 0 then
		return noop
	end
	if n == 1 then
		local fn = select(1, ...)
		if not fn then
			return noop
		end
		assert(iscallable(fn), "expected a function or nil, got " .. type(fn))
		return fn
	end
	local funcs = {}
	for i = 1, n do
		local fn = select(i, ...)
		if fn ~= nil then
			assert(iscallable(fn), "expected a function or nil, got " .. type(fn))
			funcs[#funcs + 1] = fn
		end
	end
	return function(...)
		for _, f in ipairs(funcs) do
			f(...)
		end
	end
end

function luce.call(fn, ...)
	if fn then
		return fn(...)
	end
end

function luce.fn(fn, ...)
	assert(iscallable(fn), "expected a function as the first argument, got " .. type(fn))
	local args = { ... }
	return function(...)
		local a = luce.concat(args, { ... })
		return fn(unpack(a))
	end
end

-- String functions

function luce.split(str, sep)
	if not sep then
		return luce.array(str:gmatch("([%S]+)"))
	else
		assert(sep ~= "", "empty separator")
		local psep = patternescape(sep)
		return luce.array((str .. sep):gmatch("(.-)(" .. psep .. ")"))
	end
end

function luce.format(str, vars)
	if not vars then
		return str
	end
	local f = function(x)
		local index = tonumber(x)
		if index then
			return tostring(vars[index])
		else
			return tostring(vars[x])
		end
	end
	return (str:gsub("{(.-)}", f))
end

function luce.trim(str, chars)
	if not chars then
		return str:match("^[%s]*(.-)[%s]*$")
	end
	chars = patternescape(chars)
	return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function luce.wordwrap(str, limit)
	limit = limit or 72
	local check
	if type(limit) == "number" then
		check = function(s)
			return #s >= limit
		end
	else
		check = limit
	end
	local rtn = {}
	local line = ""
	for word, spaces in str:gmatch("(%S+)(%s*)") do
		local s = line .. word
		if check(s) then
			table.insert(rtn, line .. "\n")
			line = word
		else
			line = s
		end
		for c in spaces:gmatch(".") do
			if c == "\n" then
				table.insert(rtn, line .. "\n")
				line = ""
			else
				line = line .. c
			end
		end
	end
	table.insert(rtn, line)
	return table.concat(rtn)
end

-- Miscellaneous functions

function luce.time(fn, ...)
	local start = os.clock()
	local rtn = { fn(...) }
	return (os.clock() - start), unpack(rtn)
end

local ripairs_iter = function(t, i)
	i = i - 1
	local v = t[i]
	if v ~= nil then
		return i, v
	end
end

function luce.ripairs(t)
	return ripairs_iter, t, (#t + 1)
end

function luce.dostring(str)
	return assert((loadstring or load)(str))()
end

function luce.hotswap(modname)
	local oldglobal = luce.clone(_G)
	local updated = {}
	local function update(old, new)
		if updated[old] then
			return
		end
		updated[old] = true
		local oldmt, newmt = getmetatable(old), getmetatable(new)
		if oldmt and newmt then
			update(oldmt, newmt)
		end
		for k, v in pairs(new) do
			if type(v) == "table" then
				update(old[k], v)
			else
				old[k] = v
			end
		end
	end
	local err = nil
	local function onerror(e)
		for k in pairs(_G) do
			_G[k] = oldglobal[k]
		end
		err = luce.trim(e)
	end
	local ok, oldmod = pcall(require, modname)
	oldmod = ok and oldmod or nil
	xpcall(function()
		package.loaded[modname] = nil
		local newmod = require(modname)
		if type(oldmod) == "table" then
			update(oldmod, newmod)
		end
		for k, v in pairs(oldglobal) do
			if v ~= _G[k] and type(v) == "table" then
				update(v, _G[k])
				_G[k] = v
			end
		end
	end, onerror)
	package.loaded[modname] = oldmod
	if err then
		return nil, err
	end
	return oldmod
end

function luce.trace(...)
	local info = debug.getinfo(2, "Sl")
	local t = { info.short_src .. ":" .. info.currentline .. ":" }
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = string.format("%g", luce.round(x, 0.01))
		end
		t[#t + 1] = tostring(x)
	end
	print(table.concat(t, " "))
end

function luce.color(str, mul)
	mul = mul or 1
	local r, g, b, a
	r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
	if r then
		r = tonumber(r, 16) / 0xff
		g = tonumber(g, 16) / 0xff
		b = tonumber(b, 16) / 0xff
		a = 1
	elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
		local f = str:gmatch("[%d.]+")
		r = (f() or 0) / 0xff
		g = (f() or 0) / 0xff
		b = (f() or 0) / 0xff
		a = f() or 1
	else
		error(("bad color string '%s'"):format(str))
	end
	return r * mul, g * mul, b * mul, a * mul
end

function luce.uuid()
	local fn = function(x)
		local r = math.random(16) - 1
		r = (x == "x") and (r + 1) or (r % 4) + 9
		return ("0123456789abcdef"):sub(r, r)
	end
	return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

-- random functions

function luce.random(a, b)
	if not a then
		a, b = 0, 1
	end
	if not b then
		a, b = 0, a
	end
	return a + math.random() * (b - a)
end

function luce.randomchoice(t)
	return t[math.random(#t)]
end

function luce.weightedchoice(t)
	local sum = 0
	for _, v in pairs(t) do
		assert(v >= 0, "weight value is less than zero")
		sum = sum + v
	end
	assert(sum ~= 0, "all weights are zero")
	local rnd = luce.random(sum)
	for k, v in pairs(t) do
		if rnd < v then
			return k
		end
		rnd = rnd - v
	end
end

setmetatable(luce, {
	__call = function(_, ...)
		return luce.chain(...)
	end,
})

return luce
