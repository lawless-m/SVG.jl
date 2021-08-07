#!/usr/bin/julia

push!(LOAD_PATH, "/home/matt/Documents/julia/jsvg/")

using SVG

using Images

bw = load(ARGS[1])

height, width = size(bw)
hscale = 5
wscale = 5

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

	pts = Vector{Tuple{Float64, Float64}}(undef, length(tps))
	for x in 1:length(tps)
		pts[x] = (x, yo+tps[x])
	end
	pts
end

SVG.open(stdout, 2hscale * height, 2wscale * width)
lstyle = SVG.blackline(0.5)
for h in 1:height
	pts = row(2hscale*h, map(Float64, map(Gray, bw[h, :])))
	SVG.polyline(stdout, pts, lstyle)
end
SVG.close(stdout)
