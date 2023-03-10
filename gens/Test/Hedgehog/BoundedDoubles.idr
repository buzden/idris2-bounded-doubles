module Test.Hedgehog.BoundedDoubles

import Data.Buffer
import Data.Bounded
import Data.Double.Bounded
import Data.Vect

import Hedgehog

%default total

public export
ClosestToZero : Double
ClosestToZero = 2.22507e-308

public export
data Eps = MkEps Double

EPS : Eps => Double
EPS @{MkEps x} = x

namespace Double

  export
  eqUpToEps : Eps => Double -> Double -> Bool
  eqUpToEps x y = abs (x - y) <= EPS

namespace BoundedDouble

  export
  eqUpToEps : Eps => DoubleBetween l u -> DoubleBetween l u -> Bool
  eqUpToEps = eqUpToEps `on` (.asDouble)

export
veryAnyDouble : Gen Double
veryAnyDouble = unsafePerformIO . doubleFromBits64 <$> bits64 constantBounded
  where
    doubleFromBits64 : HasIO io => Bits64 -> io Double
    doubleFromBits64 n = do
      Just bf <- newBuffer 8
        | Nothing => pure $ 0.0/0
      setBits64 bf 0 n
      getDouble bf 0

export
anySolidDouble : Gen SolidDouble
anySolidDouble = veryAnyDouble >>= \x => case (decSo $ NegInf <= x, decSo $ x <= PosInf) of
  (Yes lp, Yes rp) => pure $ BoundedDouble x
  _                => element [0, ClosestToZero, MinDouble, MaxDouble, NegInf, PosInf] <&> \x => BoundedDouble x @{believe_me Oh} @{believe_me Oh}

export
boundedDoubleCorrect : {l, u : _} -> DoubleBetween l u -> PropertyT ()
boundedDoubleCorrect x = do
  annotate "\{show l} <= \{show x} <= \{show u}"
  assert $ l <= x.asDouble && x.asDouble <= u

export
numericDouble : (canNegInf, canPosInf : Bool) -> Gen Double
numericDouble canNegInf canPosInf = map purify $ double $ exponentialDoubleFrom 0 MinDouble MaxDouble
  where
    purify : Double -> Double
    purify x = if not canPosInf && x == PosInf
               || not canNegInf && x == NegInf
               || not (x == x)
               then 0 else x

export
nonNegativeDouble : (canPosInf : Bool) -> Gen Double
nonNegativeDouble canPosInf = md <$> numericDouble canPosInf canPosInf
  where
    md : Double -> Double
    md x = if x < 0 then negate x else x

export
anyBoundedDouble : (l, u : Double) -> (0 _ : So $ l <= u) => Gen $ DoubleBetween l u
anyBoundedDouble l u = do
  let inBounds : Double -> Bool
      inBounds x = l <= x && x <= u
  let ifInBounds : Double -> Maybe Double
      ifInBounds x = if inBounds x then Just x else Nothing
  let basic : Gen Double
      basic = element $ reorder $ l :: u :: fromList (mapMaybe ifInBounds [0, ClosestToZero, MinDouble, MaxDouble, NegInf, PosInf])
  x <- choice
         [ basic
         , double (exponentialDouble (l `max` MinDouble) (u `min` MaxDouble)) >>= \x =>
             if inBounds x then pure x else basic
         ]
  pure $ BoundedDouble x @{believe_me Oh} @{believe_me Oh}
  where
    reorder : forall k, a. Vect (S k) a -> Vect (S k) a
    reorder $ a::b::c::rest = c::a::b::rest
    reorder xs              = xs

export
someBoundedDouble : Gen (l ** u ** DoubleBetween l u)
someBoundedDouble = do
  l <- numericDouble True True
  u <- numericDouble True True
  let (l, u) = (min l u, max l u)
  x <- anyBoundedDouble l u @{believe_me Oh}
  pure (l ** u ** x)

--- Special common properties ---

export
un_corr : {l, u, l', u' : _} -> (0 _ : So $ l <= u) => (DoubleBetween l u -> DoubleBetween l' u') -> Property
un_corr f = property $ do
  x <- forAll $ anyBoundedDouble _ _
  boundedDoubleCorrect $ f x
