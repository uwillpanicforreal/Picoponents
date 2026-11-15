-- Picoponents (c) 2026 uwillpanic, MIT License

include("/sources/Picoponents.p64/src/bench.lua")

function _init()
  bench.addCase("empty loop", function(n)
    for _ = 1, n do
    end
  end)
end

local resultsPrinted = false
function _update()
  local resultsReady = bench.doStep()

  if not resultsPrinted and resultsReady then
    bench.printResults()
    resultsPrinted = true
  end
end
