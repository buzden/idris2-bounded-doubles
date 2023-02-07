<!-- idris
module README

import Data.Double.Bounded

%default total

%hide Prelude.sqrt
-->

# Doubles with type-level bounds

Sometimes you need to know in static that a double value is in particular range.

```idris
failing "Can't find an implementation"

  wrong : Double
  wrong = cast $ sqrt (-1.0)
```

Say, you want to get rid of `NaN`s and their unpleasant behaviour.
You can use `SolidDouble` for this:

```idris
negative : SolidDouble -> Bool
negative x = if x < 0 then True else False
-- `False` result means non-negative, singe `NaN` can't be passed

failing "Can't find an implementation"

  w : Bool
  w = negative $ 0.0/0.0
```

Sometimes, you need to work with only a finite double.
Say, `sin` function returns a reasonable (non-NaN) value only being given a finite double.
For this, you can be `FiniteDouble`:

```idris
relSin : FiniteDouble -> FiniteDouble
relSin x = relaxToFinite $ sin x
```

Say, you want to know that the given value is in particular range, to be able to use it further in a limited context.
Say, we know that we can't `sqrt` negative numbers, but we know that `sin` produces a value between `-1` and `1`.
So, we can be sure about the bounds:

```idris
comp : FiniteDouble -> DoubleBetween 0 2
comp x = sqrt $ (sin x + 1) * 2
```
