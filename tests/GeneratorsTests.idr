module GeneratorsTests

import Test.Golden.RunnerHelper

main : IO ()
main = goldenRunner
  [ "Hedgehog generators for bounded doubles" `atDir` "generators"
  ]
