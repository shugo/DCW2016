require "nyaplot"
require "nyaplot_utils"

M = 0
S = 1

def f(x)
  1 / Math.sqrt(2 * Math::PI * S ** 2) * Math.exp(-(x - M) ** 2 / (2 * S ** 2))
end

x = -3.step(3, 0.1).to_a
y = x.map { |i| f(i) }

plot = Nyaplot::Plot.new
plot.add(:line, x, y)
plot.export_svg("normdist.svg")
