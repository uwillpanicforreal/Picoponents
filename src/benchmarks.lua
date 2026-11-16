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
  ---@diagnostic disable-next-line: unused-local
  local benchTable = { val = 1 }
  ---@diagnostic disable-next-line: unused-local
  local dest
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-local
    dest = benchTable.val
  end
end

---benchmark for local function lookup
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
---benchmark for local function lookup
---@type bench.Benchmark
local function globalReadBenchmark(n)
  ---@diagnostic disable-next-line: unused-local
  local val = 1
  for _ = 1, n do
    ---@diagnostic disable-next-line: unused-local
    val = globalval
  end
end
benchmarks = {}
benchmarks.init = function()
  bench.addCase("global function", globalFunctionBenchmark)
  bench.addCase("local function", localFunctionBenchmark)
  bench.addCase("table read", tableReadBenchmark)
  bench.addCase("local read", localReadBenchmark)
  bench.addCase("global read", globalReadBenchmark)
end
