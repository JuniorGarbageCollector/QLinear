{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module Internal.Quasi.Matrix.Quasi (matrix, vector) where

import Internal.Matrix
import qualified Internal.Quasi.Matrix.Expression.Parser as Parser
import qualified Internal.Quasi.Matrix.Expression.Quote as Quote
import Internal.Quasi.Quasi
import Language.Haskell.TH.Quote
import Language.Haskell.TH.Syntax
import Internal.Quasi.Matrix.Pattern.Quote

-- | Macro constructor for 'QLinear.Matrix.Matrix'
--
-- >>> [matrix| 1 2; 3 4 |]
-- [1,2]
-- [3,4]
-- >>> :t [matrix| 1 2; 3 4|]
-- [matrix| 1 2; 3 4|] :: Num a => Matrix 2 2 a
matrix :: QuasiQuoter
matrix =
  QuasiQuoter
    { quoteExp = Quote.expr Parser.matrix,
      quotePat = pat,
      quoteType = notDefined "Type",
      quoteDec = notDefined "Declaration"
    }
  where
    notDefined = isNotDefinedAs "matrix"

-- | Macro constructor for 'QLinear.Matrix.Vector'.
--
-- >>> [vector| 1 2 3 4 |]
-- [1]
-- [2]
-- [3]
-- [4]
-- >>> :t [vector| 1 2 3 4 |]
-- [vector| 1 2 3 4 |] :: Num a => Vector 4 a
vector :: QuasiQuoter
vector =
  QuasiQuoter
    { quoteExp = vectorExpr,
      quotePat = notDefined "Pattern",
      quoteType = notDefined "Type",
      quoteDec = notDefined "Declaration"
    }
  where
    notDefined = isNotDefinedAs "vector"

vectorExpr :: String -> Q Exp
vectorExpr source = f <$> Quote.expr Parser.vector source
  where
    f = AppE (VarE 'toVector)

toVector :: Matrix n 1 a -> Vector n a
toVector = id
