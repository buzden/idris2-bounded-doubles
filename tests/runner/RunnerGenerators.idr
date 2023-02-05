module RunnerGenerators

import BaseDir

import Test.Golden.RunnerHelper

RunScriptArg where
  runScriptArg = baseTestsDir ++ "/.pack_lock"

main : IO ()
main = goldenRunner
  [ "Hedgehog generators for bounded doubles" `atDir` "generators"
  ]
