#!/home/matt/bin/julia

push!(LOAD_PATH, "/home/matt/Documents/julia/jsvg/")
push!(LOAD_PATH, "/home/matt/Documents/julia/3dprinting/")

using SVG
using Mesh

const THRESH = 0.0001

struct QFace
	i
	ab
	bc
	ca
	area
	function QFace(n, i)
		ai,bi,ci = abci(n, i)
		a,b,c = abc(n, i)
	        ab, bc, ca = b-a, c-b, a-c
		area = 0.5 * abs(magnitude(ab) * sin(angleXY(ab) - angleXY(ca))) * magnitude(ca)
#==
if area < 0.001
println("i ", i, " area ", area)
println(n.faces[i])
println("ai ", ai, " bi ", bi, " ci ", ci)
println("a ", a, " b ", b, " c ", c)
end
==#
		new(i, (angleXY(ab), magnitude(ab)), (angleXY(bc), magnitude(bc)), (angleXY(ca), magnitude(ca)), area)
	end
end

struct Quad
	qfaces::Tuple{QFace, QFace}
end

quad_area(q) = q.qfaces[1].area + q.qfaces[2].area

function qsvg(fid, n, q::Quad, styles, style) 
	for qf in q.qfaces
		a,b,c = abc(n, qf.i)

		SVG.polyline(fid, [a, b], styles[style])
		SVG.polyline(fid, [b, c], styles[style])
		SVG.polyline(fid, [c, a], styles[style])
	end
end

function quad(n, a, b, c, d)
	s = SVG.blackline(1)
	f1 = face!(n, a, b, c, "visible", "visible", "hidden")
	f2 = face!(n, a, c, d, "hidden", "visible", "visible")
	Quad((QFace(n, f1), QFace(n, f2)))
end

function biggest_face(q)
	biga = -Inf
	bigi = 0
	for i in 1:length(q.qfaces)
		if q.qfaces[i].area > biga
			biga = q.qfaces[i].area
			bigi = i
		end
	end
	bigi
end

function random_p_on_qface(n, qface)
	a,_,c = abc(n, qface.i)
	rand() = 0.5
	p1 = a + rand() * qface.ab[2] * Vertex(cos(qface.ab[1]), sin(qface.ab[1]))
	p2 = c - p1
	vertex!(n, p1 + rand() * magnitude(p2) * Vertex(cos(angleXY(p2)), sin(angleXY(p2))))
end

function orth(n, rpi, fi)
	rp = n.vertices[rpi]
	face = n.faces[fi]
	new_faces = Vector{Face}()
	
	ai,bi,ci = abci(n, face)
	a,b,c = n.vertices[[ai,bi,ci]]

	function twoface!(vai, vbi, vpi)
		push!(new_faces, Face(Edge(vai, vpi, "visible"), Edge(vpi, rpi, "visible"), Edge(rpi, vpi, "hidden")))
		push!(new_faces, Face(Edge(vpi, vbi, "visible"), Edge(vbi, rpi, "hidden"), Edge(rpi, vpi, "visible")))
	end 

	if face.ab.style != "hidden"
		p = intersect(a, b, rp)
		pi = vertex!(n, p)
		twoface!(ai, bi, pi)
	end
	
	if face.bc.style != "hidden"
		p = intersect(b, c, rp)
		pi = vertex!(n, p)
		twoface!(bi, ci, pi)
	end
	if face.ca.style != "hidden"
		p = intersect(c, a, rp)
		pi = vertex!(n, p)
		twoface!(ci, ai, pi)
	end

	faces = [fi]

	if length(new_faces) > 0
		n.faces[fi] = new_faces[1]
		for i in 2:length(new_faces)
			push!(faces, face!(n, new_faces[i]))
		end
	end
	faces

end

function intersect(a, b, c, d)

	ab = b - a
	cd = d - c

	a_ab = angleXY(ab)

	if abs(a_ab - angleXY(cd)) < THRESH
		println("parallel", a_ab - angleXY(cd) )
		return 
	end

	function mag(t)
		p = a + t * ab
		magnitude(p - c) + magnitude(p - d)
	end

	intersect(a, b, mag)
end

intersect(a, b, v::Vertex) = intersect(a, b, t->magnitude((a + t * (b-a)) - v))

function intersect(a, b, mag::Function)
	ab = b - a

	s = 0
	sd = mag(s)
	f = 1.0
	fd = mag(f)
	dt = 0.5
	t = (s+f)/2
	dd = Inf
	k = 0
	while dd > THRESH && k < 1000
		td = mag(t)
		tdp = mag(t+dt)
		tdm = mag(t-dt)

		if td - tdp > 0
			s = t
			dd = abs(td - tdp)
		elseif td - tdm > 0
			f = t
			dd = abs(td - tdm)
		end
		dt /= 2
		t = (s+f)/2
		k += 1
	end
	a + t * ab
end

function divide_q(n, q)
	faces = Vector{Int}()
	rpi = random_p_on_qface(n, q.qfaces[biggest_face(q)])
	for i in 1:length(q.qfaces) 
		faces = vcat(faces, orth(n, rpi, q.qfaces[i].i))
	end
	q1 = Quad((QFace(n, faces[1]), QFace(n, faces[8]))) 
	q2 = Quad((QFace(n, faces[2]), QFace(n, faces[3]))) 
	q3 = Quad((QFace(n, faces[4]), QFace(n, faces[5]))) 
	q4 = Quad((QFace(n, faces[6]), QFace(n, faces[7]))) 

	[q1, q2, q3, q4]
end

function divide(n, q)
	if quad_area(q) < 1000
		return
	end

	for qq in divide_q(n, q)
		divide(n, qq)
	end
end

fid = open("test.svg", "w+")
SVG.open(fid, 1350, 1350)

styles = Dict{String, String}()
styles["visible"] = SVG.blackline(1)
styles["hidden"] = SVG.style("none", "red", 0.1)
styles["blue"] = SVG.style("none", "blue", 3)
styles["green"] = SVG.style("none", "green", 3)
styles["magenta"] = SVG.style("none", "magenta", 3)
styles["red"] = SVG.style("none", "red", 3)
styles[""] = ""


n = Net()
vertex!(n, 50,50)
vertex!(n, 50,300)
vertex!(n, 300,300)
vertex!(n, 300,50)

vertex!(n, 250,790)
vertex!(n, 394,400)
vertex!(n, 936,657)
vertex!(n, 678,931)

q1 = quad(n, 1, 2, 3, 4)
q2 = quad(n, 5, 6, 7, 8)

divide(n, q1)

divide(n, q2)

SVG.meshXY(fid, n, styles)

SVG.close(fid)
close(fid)


