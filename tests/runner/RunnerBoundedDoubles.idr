module RunnerBoundedDoubles

import BaseDir

import Test.Golden.RunnerHelper

RunScriptArg where
  runScriptArg = baseTestsDir ++ "/.pack_lock"

main : IO ()
main = goldenRunner
  [ "Documentation" `atDir` "docs"
  , "Bounded Double type" `atDir` "bounded-double"
  ]
