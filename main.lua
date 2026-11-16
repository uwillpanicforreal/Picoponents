-- Picoponents (c) 2026 uwillpanic, MIT License

include("/sources/Picoponents.p64/src/bench.lua")
include("/sources/Picoponents.p64/src/benchmarks.lua")

function _init()
  benchmarks.init()
end

local resultsPrinted = false
function _update()
  local resultsReady = bench.doStep()

  if not resultsPrinted and resultsReady then
    bench.printResults()
    resultsPrinted = true
  end
end
