module BelieveMeSpec

import Data.Buffer
import Data.Bounded
import Data.Double.Bounded

import Hedgehog

import Test.Common
import Test.Hedgehog.BoundedDoubles

lteRefl_prop : Property
lteRefl_prop = property $ do
  x <- forAll veryAnyDouble
  assert $ x == x `implies` x <= x

lteNotNaNL_prop : Property
lteNotNaNL_prop = property $ do
  x <- forAll veryAnyDouble
  y <- forAll veryAnyDouble
  assert $ x <= y `implies` x == x

lteNotNaNR_prop : Property
lteNotNaNR_prop = property $ do
  x <- forAll veryAnyDouble
  y <- forAll veryAnyDouble
  assert $ y <= x `implies` x == x

lteTrans_prop : Property
lteTrans_prop = property $ do
  x <- forAll veryAnyDouble
  y <- forAll veryAnyDouble
  z <- forAll veryAnyDouble
  assert $ (x <= y && y <= z) `implies` x <= z
  -- very ineffective check...

lteNegInf_prop : Property
lteNegInf_prop = property $ do
  x <- forAll veryAnyDouble
  assert $ x == x `implies` NegInf <= x

ltePosInf_prop : Property
ltePosInf_prop = property $ do
  x <- forAll veryAnyDouble
  assert $ x == x `implies` x <= PosInf

zormin_prop : Property
zormin_prop = property $ do
  l <- forAll $ numericDouble True True
  u <- forAll $ numericDouble True True
  let z = zormin l u
  annotateShow z
  assert $ z == 0 || z == l || z == u
  assert $ l <= 0 && 0 <= u `implies` z == 0

lteMin_prop : Property
lteMin_prop = property $ do
  x <- forAll veryAnyDouble
  assert $ x /= NegInf && x /= PosInf && x == x `implies` MinDouble <= x

lteMax_prop : Property
lteMax_prop = property $ do
  x <- forAll veryAnyDouble
  assert $ x /= NegInf && x /= PosInf && x == x `implies` x <= MaxDouble

lteFromLt_prop : Property
lteFromLt_prop = property $ do
  x <- forAll veryAnyDouble
  y <- forAll veryAnyDouble
  assert $ x < y `implies` x <= y

lteRev_prop : Property
lteRev_prop = property $ do
  x <- forAll veryAnyDouble
  y <- forAll veryAnyDouble
  assert $ x == x && y == y && not (x <= y) `implies` y < x

main : IO ()
main = test
  [ "believe_me lte" `MkGroup`
      [ ("lteRefl", lteRefl_prop)
      , ("lteNotNaNL", lteNotNaNL_prop )
      , ("lteNotNaNR", lteNotNaNR_prop )
      , ("lteTrans", lteTrans_prop)
      , ("lteNegInf", lteNegInf_prop)
      , ("ltePosInf", ltePosInf_prop)
      , ("lteMin", lteMin_prop)
      , ("lteMax", lteMax_prop)
      , ("lteFromLt", lteFromLt_prop)
      , ("lteRev", lteRev_prop)
      ]
  , "aux doubles funs" `MkGroup`
      [ ("zormin", zormin_prop)
      ]
  ]
