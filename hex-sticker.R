library(hexSticker)
library(ggplot2)
library(ggforce)
library(dplyr)
library(ggfx)

rotate <- function(df, angle) {
  
  angle <- pi * angle
  x <- df$x
  y <- df$y
  
  df$x <- x * cos(angle) - y * sin(angle)
  df$y <- x * sin(angle) + y * cos(angle)
  
  df
  
} 

arrow <- rotate(angle = -1/3, tibble(
  x = c(-2, .5, .5, 2.2, .5, .5, -2),
  y = c(1, 1, 1.7, 0 , -1.7, -1, -1)
))

hex <- seq(0, 2, by = 1/3) %>%
  purrr::map_df(rotate, df = tibble(x = 0, y = 3))

ragg::agg_png(
  "man/figures/logo.png", 
  width = 500, height = 500, scaling = 1.2
)

ggplot(arrow, aes(x, y)) +
  geom_shape(data = hex, fill = "#ecd444", colour = "#6e2594", size = 4) +
  with_shadow(geom_shape(
    radius = 0.002, fill = "#ffffff", colour = "#6e2594", size = 3
  ), sigma = 10, x_offset = -10, y_offset = -5, colour = "grey40") +
  annotate(
    "text", x = 0.05, y = -0.05, label = "quickReport", family = "Oleo Script", 
    size = 22, colour = "#E2E2E2"
  ) +
  annotate(
    "text", x = 0, y = 0, label = "quickReport", family = "Oleo Script", 
    size = 22, colour = "#003249"
  ) +
  theme_void() + 
  coord_cartesian(c(-3, 3), c(-3, 3))

dev.off()
