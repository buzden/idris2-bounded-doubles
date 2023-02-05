module Test.Common

import Data.So
import Data.Vect

import Hedgehog

import Test.Hedgehog.BoundedDoubles

%default total

public export
implies : Bool -> Bool -> Bool
implies a c = not a || c

export
Show (So x) where
  show _ = "Oh"

export
somewhatInteger : Gen Integer
somewhatInteger = choice
  [ integer $ constantFrom 0 (-1000000000000) 1000000000000
  , cast <$> numericDouble False False
  , foldl (+) 0 . map cast <$> vect 5 (numericDouble False False)
  ]

export
somewhatNat : Gen Nat
somewhatNat = choice
  [ nat $ constant 0 1000000000000
  , cast <$> numericDouble False False
  , foldl (+) 0 . map cast <$> vect 5 (numericDouble False False)
  ]

--- Retry "filtration" facilities ---

public export
interface BuildableFrom from (0 what : from -> Type) where
  tryBuild : (f : from) -> Maybe $ what f

export
BuildableFrom f a => BuildableFrom f b => BuildableFrom f (\x => Either (a x) (b x)) where
  tryBuild x = Left <$> tryBuild x <|> Right <$> tryBuild x

export
BuildableFrom f a => BuildableFrom f b => BuildableFrom f (\x => (a x, b x)) where
  tryBuild x = [| (tryBuild x, tryBuild x) |]

export
{g : _} -> BuildableFrom f (So . g) where
  tryBuild x = case decSo $ g x of
                 Yes y => Just y
                 No _  => Nothing

export
plus : Gen a -> (0 b : _) -> BuildableFrom a b => Gen $ Maybe (x : a ** b x)
plus g _ = g <&> \x => tryBuild x <&> \y => (x ** y)

export
forAllDefault : Show a => Lazy a -> Gen (Maybe a) -> PropertyT a
forAllDefault def g = fromMaybe def <$> forAll g
