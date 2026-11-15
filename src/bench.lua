---returns args to be passed to benchmark. Untimed, and run before each rep
---@alias bench.Setup fun(): any

---function to be benched. loops n times internally, takes the result of setup as args.
---@alias bench.Benchmark fun(n: integer, args: any)

---@class bench.Case
---@field name string unique name
---@field benchmark bench.Benchmark
---@field n integer n to be passed to benchmark
---@field elementsPerN number Number of elements that are processed per run of the internal loop. Just modifies final output
---@field setup? bench.Setup
---@field reps integer Number of reps this test will be repeated for, the minimum result being selected for the record
---@field repsDone integer Number of reps that have been done
---@field minimums {benchcycles: number, basecycles: number} lowest number of cycles taken for both the bench and its baseline

---Options for a given case
---@class bench.CaseOpts
---@field n? integer n to be passed to benchmark. Default 1000
---@field elementsPerN? number Number of elements that are processed per run of the internal loop. Just modifies final output. Default 1
---@field setup? bench.Setup
---@field reps? integer Number of reps this test will be repeated for, the minimum result being selected for the record. Default 5

---@class bench
bench = {}

---manual: 16,777,216 (2^24) cycles/sec; ÷60 for one frame
bench.CYCLES_PER_FRAME = 2 ^ 24 / 60
---@type bench.Case[]
bench.cases = {}

---@return number cycles cycles used so far this frame (stat(1) is a fraction of the frame)
function bench.now()
  return stat(1) * bench.CYCLES_PER_FRAME
end

---benchmark for an empty loop, used to get baseline
---@type bench.Benchmark
local function emptyLoopBenchmark(n)
  ---@diagnostic disable-next-line: empty-block
  for _ = 1, n do
  end
end

---times benchmark(n, args) for cycles used
---@param benchmark bench.Benchmark
---@param n integer number of iterations to be passed to benchmark
---@param args any arguments to be passed to benchmark
---@return number cycles number of cycles it took to run benchmark, raw, without any consideration for overhead or baseline
function bench.measure(benchmark, n, args)
  local startCycles = bench.now()
  benchmark(n, args)
  local endCycles = bench.now()
  return endCycles - startCycles
end

---Wrapper method for measuring a benchmark function and empty loop baseline
---@param benchmark bench.Benchmark
---@param n integer n to be passed to benchmark
---@param args any args to be passed to benchmark
---@return number benchcycles number of cycles it took to run the benchmark
---@return number basecycles number of cycles it took to run the empty loop benchmark
function bench.measureWithBaseline(benchmark, n, args)
  local benchcycles = bench.measure(benchmark, n, args)
  local basecycles = bench.measure(emptyLoopBenchmark, n)

  return benchcycles, basecycles
end

---Adds a case for benchmarking to an ordered list
---@param name string unique name used for console output
---@param benchmark bench.Benchmark
---@param opts? bench.CaseOpts
function bench.case(name, benchmark, opts)
  local caseOpts = opts or {}
  bench.cases[#bench.cases + 1] = {
    name = name,
    benchmark = benchmark,
    n = caseOpts.n or 1000,
    elementsPerN = caseOpts.elementsPerN or 1,
    setup = caseOpts.setup,
    reps = caseOpts.reps or 5,
    repsDone = 0,
    minimums = {
      benchcycles = math.huge,
      basecycles = math.huge,
    },
  }
end

---Run the first benchmark where repsDone<reps. Runs setup untimed, then updates minimums and increments repsDone for current case
---@return boolean finished true when, for each case, repsDone>=reps, otherwise false
function bench.step()
  for _, case in ipairs(bench.cases) do
    if case.repsDone < case.reps then
      local args = case.setup()
      local measure = bench.measure(case.benchmark, case.n, args)
      local overhead = bench.measure(emptyLoopBenchmark, case.n)
      if measure < case.minimums.basecycles then
        case.minimums.basecycles = measure
        case.minimums.benchcycles = overhead
      end
      return false
    end
  end
  return true
end

-- returns: list of { name, cycles, per_element, reps }
-- with the baseline subtracted and divided by n (and by per)
function bench.results() end

-- draw the results table at x, y (from _draw, only after step() returns true)
function bench.draw(x, y) end

-- stretch: double n until the case uses ~40% of a frame; returns the chosen n
function bench.calibrate(benchmark, args) end

function bench.doUpdate() end
function bench.doInit()
  printh(bench.measure(emptyLoopBenchmark, 1000) / 1000)
  printh(bench.measure(emptyLoopBenchmark, 2000) / 2000)
  printh(bench.measure(emptyLoopBenchmark, 4000) / 4000)
end
