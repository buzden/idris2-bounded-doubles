module LibraryTests

import Test.Golden.RunnerHelper

main : IO ()
main = goldenRunner
  [ "Documentation" `atDir` "docs"
  , "Bounded Double type" `atDir` "bounded-double"
  ]
