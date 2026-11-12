bench = {}

-- manual: 16,777,216 cycles/sec; ÷60 for one frame
bench.CYCLES_PER_FRAME = --

-- returns: cycles used so far this frame (stat(1) is a fraction of the frame)
function bench.now() end

-- register a case
-- fn(n, ctx):  runs its OWN loop n times (the timed region)
-- opts.n:      iterations (default: your choice)
-- opts.per:    elements covered per iteration (bulk ops), so results can be per element
-- opts.setup:  untimed; runs before each rep, returns ctx
-- opts.reps:   repetitions (default: your choice)
function bench.case(name, fn, opts) end

-- time ONE call to fn(n, ctx) within the current frame
-- returns: raw cycles (no baseline subtracted)
function bench.measure(fn, n, ctx) end

-- run the next (case, rep); call once per _update
-- returns: true when every case has run all of its reps
function bench.step() end

-- returns: list of { name, cycles, per_element, reps }
-- with the baseline subtracted and divided by n (and by per)
function bench.results() end

-- draw the results table at x, y (from _draw, only after step() returns true)
function bench.draw(x, y) end

-- stretch: double n until the case uses ~40% of a frame; returns the chosen n
function bench.calibrate(fn, ctx) end
