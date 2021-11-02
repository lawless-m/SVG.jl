module SVGMesh

using Mesh
using SVG

function meshXY(fid, n::Net, styles::Dict)
	for f in n.faces
		polyline(fid, n.vertices[[f.ab.from, f.ab.to]], styles[f.ab.style])
		polyline(fid, n.vertices[[f.bc.from, f.bc.to]], styles[f.bc.style])
		polyline(fid, n.vertices[[f.ca.from, f.ca.to]], styles[f.ca.style])
	end
end

###
end
