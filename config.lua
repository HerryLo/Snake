local config = {}

config.cellSize = 20
config.cols = 40
config.rows = 24

config.boardOffsetX = 50
config.boardOffsetY = 90

config.baseMoveInterval = 0.14
config.speedupEvery = 5
config.speedupFactor = 0.94
config.minMoveInterval = 0.06

config.maxLeaderboardEntries = 10
config.scoresFile = "scores.txt"

config.colors = {
  bg = { 0.06, 0.07, 0.09, 1 },
  panel = { 0.10, 0.12, 0.16, 1 },
  panelBorder = { 0.22, 0.25, 0.33, 1 },
  gridLine = { 0.35, 0.37, 0.44, 0.65 },
  snakeHead = { 0.45, 0.72, 1.00, 1 },
  snakeHeadHighlight = { 0.82, 0.92, 1.00, 0.18 },
  snakeHeadOutline = { 0.06, 0.08, 0.10, 0.85 },
  snakeBody = { 0.12, 0.74, 0.42, 1 },
  food = { 0.98, 0.40, 0.36, 1 },
  foodGlow = { 1.00, 0.55, 0.45, 0.20 },
  appleDark = { 0.78, 0.18, 0.20, 1 },
  appleOutline = { 0.12, 0.08, 0.09, 0.75 },
  appleSpecular = { 1.00, 1.00, 1.00, 0.22 },
  appleStem = { 0.32, 0.22, 0.12, 1 },
  appleLeaf = { 0.25, 0.85, 0.45, 1 },
  appleLeafShadow = { 0.10, 0.55, 0.25, 0.6 },
  appleLeafOutline = { 0.06, 0.20, 0.10, 0.75 },
  eyeWhite = { 0.95, 0.97, 1.00, 0.95 },
  eyePupil = { 0.05, 0.06, 0.08, 0.95 },
  text = { 0.93, 0.95, 0.98, 1 },
  muted = { 0.66, 0.70, 0.78, 1 },
  danger = { 1.00, 0.32, 0.38, 1 },
}

return config

