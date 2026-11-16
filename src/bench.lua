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
---@field minimums {benchcycles: number,overheadcycles: number} lowest number of cycles taken for both the bench and its overhead
---@field result number Cycles per element, taking into account n, elementsPerN, and overheadcycles. Updates every rep.

---Options for a given case
---@class bench.CaseOpts
---@field n? integer n to be passed to benchmark. Default 1000
---@field elementsPerN? number Number of elements that are processed per run of the internal loop. Just modifies final output. Default 1
---@field setup? bench.Setup
---@field reps? integer Number of reps this test will be repeated for, the minimum result being selected for the record. Default 5

---@class bench
---@field cases bench.Case[]
---@field CYCLES_PER_FRAME number
bench = {
  cases = {},
  ---manual: 16,777,216 (2^24) cycles/sec; ÷60 for one frame
  CYCLES_PER_FRAME = 2 ^ 24 / 60,
}

---@return number cycles cycles used so far this frame (stat(1) is a fraction of the frame)
function bench.now()
  return stat(1) * bench.CYCLES_PER_FRAME
end

---benchmark for an empty loop, used to get overhead
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
---@return number cycles number of cycles it took to run benchmark, raw, without any consideration for fixed cost or overhead
function bench.measure(benchmark, n, args)
  local startCycles = bench.now()
  benchmark(n, args)
  local endCycles = bench.now()
  return endCycles - startCycles
end

---Wrapper method for measuring a benchmark function and empty loop overhead
---@param benchmark bench.Benchmark
---@param n integer n to be passed to benchmark
---@param args any args to be passed to benchmark
---@return number benchcycles number of cycles it took to run the benchmark
---@return number overheadcycles number of cycles it took to run the empty loop benchmark
function bench.measureWithOverhead(benchmark, n, args)
  local benchcycles = bench.measure(benchmark, n, args)
  local overheadcycles = bench.measure(emptyLoopBenchmark, n)

  return benchcycles, overheadcycles
end

---Adds a case for benchmarking to an ordered list
---@param name string unique name used for console output
---@param benchmark bench.Benchmark
---@param opts? bench.CaseOpts
function bench.addCase(name, benchmark, opts)
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
      overheadcycles = math.huge,
    },
    result = 0,
  }
end

---Run the first benchmark where repsDone<reps. Runs setup untimed, then updates minimums and increments repsDone for current case
---@return boolean finished true when, for each case, repsDone>=reps, otherwise false
function bench.doStep()
  for _, case in ipairs(bench.cases) do
    if case.repsDone < case.reps then
      local args = case.setup and case.setup()
      local measure, overhead = bench.measureWithOverhead(case.benchmark, case.n, args)
      case.minimums.overheadcycles = math.min(case.minimums.overheadcycles, overhead)
      case.minimums.benchcycles = math.min(case.minimums.benchcycles, measure)
      case.repsDone += 1
      case.result = (case.minimums.benchcycles - case.minimums.overheadcycles) / (case.n * case.elementsPerN)
      return false
    end
  end
  return true
end

---Prints the results of the benchmark using printh
function bench.printResults()
  local lines = {}
  for _, case in ipairs(bench.cases) do
    table.insert(
      lines,
      string.format("\t%-20.20s|%8.2f cycles/element\t|%3d reps", case.name, case.result, case.repsDone)
    )
  end
  printh("Benchmark results:\n" .. table.concat(lines, "\n"))
end
