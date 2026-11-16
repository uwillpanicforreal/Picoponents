function globalFunc() end
---benchmark for global function lookup
---@type bench.Benchmark
local function globalFunctionBenchmark(n)
  for _ = 1, n do
    globalFunc()
  end
end

---benchmark for local function lookup
---@type bench.Benchmark
local function localFunctionBenchmark(n)
  local function localFunc() end
  for _ = 1, n do
    localFunc()
  end
end

---benchmark for reading a value from a table
---@type bench.Benchmark
local function tableReadBenchmark(n)
  local benchTable = { val = 1 }
  ---@diagnostic disable-next-line: unused-local
  local dest
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-local
    dest = benchTable.val
  end
end

---benchmark for reading a local variable
---@type bench.Benchmark
local function localReadBenchmark(n)
  local val = 1
  ---@diagnostic disable-next-line: unused-local
  local dest
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-local
    dest = val
  end
end

globalval = 1
---benchmark for reading a global variable
---@type bench.Benchmark
local function globalReadBenchmark(n)
  ---@diagnostic disable-next-line: unused-local
  local dest = 1
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-local
    dest = globalval
  end
end

---benchmark for creating a function
---@type bench.Benchmark
local function functionCreationBenchmark(n)
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-function, unused-local
    local function test() end
  end
end

---benchmark for creating a function with an upvalue
---@type bench.Benchmark
local function upvalueBenchmark(n)
  local val = 1
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-function, unused-local
    local function test()
      return val
    end
  end
end

---benchmark for setting one value in a userdata
---@type bench.Benchmark
---@param ud userdata
local function userdataSetBenchmark(n, ud)
  for i = 0, n - 1 do
    ud:set(i, 1)
  end
end
---setup function for userdataSetBenchmark
---@type bench.Setup
local function userdataSetBenchmarkSetup(n)
  return userdata("i16", n)
end

---benchmark for getting one value in a userdata
---@type bench.Benchmark
---@param ud userdata
local function userdataGetBenchmark(n, ud)
  ---@diagnostic disable-next-line: unused-local
  local dest
  for i = 0, n - 1 do
    ---@diagnostic disable-next-line: unused-local
    dest = ud:get(i)
  end
end
---Sets up a 100 element userdata for benchmark args
---@type bench.Setup
local function userdata100ElementSetup(n)
  local ud = userdata("i16", n)

  for i = 0, n - 1 do
    ud:set(i, 1)
  end

  return ud
end

---benchmark for getting one value in a userdata via ud[x]
---@type bench.Benchmark
---@param ud userdata
local function userdataIndexedGetBenchmark(n, ud)
  ---@diagnostic disable-next-line: unused-local
  local dest
  for i = 0, n - 1 do
    ---@diagnostic disable-next-line: unused-local
    dest = ud[i]
  end
end

---benchmark for setting one value in a userdata via ud[x]
---@type bench.Benchmark
---@param ud userdata
local function userdataIndexedSetBenchmark(n, ud)
  for i = 0, n - 1 do
    ---@diagnostic disable-next-line: unused-local
    ud[i] = 2
  end
end

benchmarks = {}
function benchmarks.init()
  bench.addCase("global function", globalFunctionBenchmark)
  bench.addCase("local function", localFunctionBenchmark)
  bench.addCase("table read", tableReadBenchmark)
  bench.addCase("local read", localReadBenchmark)
  bench.addCase("global read", globalReadBenchmark)
  bench.addCase("function creation", functionCreationBenchmark)
  bench.addCase("upvalue function creation", upvalueBenchmark)
  bench.addCase("setting 1 userdata value", userdataSetBenchmark, { setup = userdataSetBenchmarkSetup })
  bench.addCase("getting 1 userdata value", userdataGetBenchmark, { setup = userdata100ElementSetup })
  bench.addCase("getting 1 userdata value via ud[x]", userdataIndexedGetBenchmark, { setup = userdata100ElementSetup })
  bench.addCase("setting 1 userdata value via ud[x]", userdataIndexedSetBenchmark, { setup = userdata100ElementSetup })
end
