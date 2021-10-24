#!/usr/bin/julia

push!(LOAD_PATH, "/home/matt/Documents/julia/jsvg/")
push!(LOAD_PATH, "/home/matt/Documents/julia/3dprinting/")

using SVG

using Images

bw = load(ARGS[1])

height, width = size(bw)
hscale = 5
wscale = 5

svg = Svg(2wscale * width, 2hscale * height)

plusminus = repeat([1,-1], wscale)

function row(yo, pxs)
	tps = Vector{Float64}(undef, 2wscale * width)
	xs = 1
	xe = 2wscale
	for x in 1:width
		tps[xs:xe] = 1.2*hscale*(1-pxs[x]) * rand(2wscale) .* plusminus
		xs += 2wscale
		xe += 2wscale
	end

	line = SVG.Polyline(length(tps), style=SVG.Style(strokewidth=0.5))
	for x in 1:length(tps)
		line.points[x] = (x, yo+tps[x])
	end
	line
end

for h in 1:height
	push!(svg.objects, row(2hscale*h, map(Float64, map(Gray, bw[h, :]))))
end

write(stdout, svg)

