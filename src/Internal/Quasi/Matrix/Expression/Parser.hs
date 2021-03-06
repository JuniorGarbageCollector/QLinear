module Internal.Quasi.Matrix.Expression.Parser where

import Internal.Quasi.Parser
import Language.Haskell.TH.Syntax

matrix :: Parser [[Exp]]
matrix = (line `sepBy` char ';') <* eof

vector :: Parser [[Exp]]
vector = map pure <$> (line <* eof)

line :: Parser [Exp]
line = spaces >> unit `endBy1` spaces

unit :: Parser Exp
unit = (var <|> num <|> inBrackets) >>= expr

num :: Parser String
num = do
  neg <- char' '-' <|> pure []
  beforeDot <- (many1 outer <> many inner) <|> char' '0'
  afterDot <- char' '.' <> many1 inner <|> mempty
  pure $ neg <> beforeDot <> afterDot
  where
    outer = oneOf ['1' .. '9']
    inner = char '0' <|> outer

inBrackets :: Parser String
inBrackets = nested '(' ')'

nested :: Char -> Char -> Parser String
nested open close = char' open <> scan (1 :: Integer)
  where
    scan 0 = pure mempty
    scan n = many (noneOf [open, close]) <> (char' open <> inc n <|> char' close <> dec n)
    inc = scan . (+ 1)
    dec = scan . (\n -> n - 1)
