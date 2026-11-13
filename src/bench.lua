bench = {}

-- manual: 16,777,216 (2^24) cycles/sec; ÷60 for one frame
bench.CYCLES_PER_FRAME = 2 ^ 24 / 60
bench.cases = {}

-- returns: cycles used so far this frame (stat(1) is a fraction of the frame)
function bench.now()
  return stat(1) * bench.CYCLES_PER_FRAME
end

local function emptyLoopBenchmark(n)
  for i = 1, n do
  end
end
-- times benchmark(n, args) for cycles used
function bench.measure(benchmark, n, args)
  local startCycles = bench.now()
  benchmark(n, args)
  local endCycles = bench.now()
  return endCycles - startCycles
end

-- Wrapper method for measuring a benchmark function and empty loop baseline. Raw values from measure
-- benchmark(n, args):  function to be benched. loops n times internally, passes result of setup as args.
-- n:                   n to be passed to benchmark
-- args:                args to be passed to benchmark
--
-- returns:
--  benchcycles:  number of cycles it took to run the benchmark
--  basecycles: number of cycles it took to run the empty loop benchmark
--
function bench.measureWithBaseline(benchmark, n, args)
  local benchcycles = bench.measure(benchmark, n, args)
  local basecycles = bench.measure(emptyLoopBenchmark, n)

  return benchcycles, basecycles
end

-- Adds a case for benchmarking to an ordered list
-- name:                unique name used for console output
-- benchmark(n, args):  function to be benched. loops n times internally, passes result of setup as args.
-- opts.n:              n to be passed to benchmark. Default 1000
-- opts.elementsPerN:   Number of elements that are processed per run of the internal loop. Just modifies final output. Default 1
-- opts.setup:          returns args to be passed to benchmark. Untimed, and run before each rep. Default nil
-- opts.reps:           Number of steps this test will be repeated for, the minimum result being selected for the record. Default 5
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

-- run the next (case, rep); call once per _update
-- returns: true when every case has run all of its reps
function bench.step() end

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
