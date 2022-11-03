extends ImmediateGeometry

onready var LineOnHookPosition : Position3D = get_node("../../Hook/FishingLineEnd")

const CYLINDER_SLICES = 6
const CYLINDER_RADIUS = 0.02

var unitCircleVertices = []

func _ready():
	# setup unit circle based off our slice count
	var sliceStep : float = (2.0 * PI) / CYLINDER_SLICES;
	var currentSliceRadians := 0.0
	
	var sliceNum = 0
	while sliceNum <= CYLINDER_SLICES:
		currentSliceRadians = sliceNum * sliceStep
		
		var vertex : Vector3
		vertex.x = cos(currentSliceRadians)
		vertex.y = 0
		vertex.z = sin(currentSliceRadians)
		
		unitCircleVertices.push_back(vertex)
		sliceNum += 1

func _process(delta):
	clear()
	
	var startPos = Vector3()
	var endPos = to_local(LineOnHookPosition.global_translation)
	
	# build top face vertices
	var topFaceVerts = []
	for sliceNum in range(CYLINDER_SLICES + 1):
		var unitVert = unitCircleVertices[sliceNum]
		var vert : Vector3
		vert.x = startPos.x + (unitVert.x * CYLINDER_RADIUS)
		vert.y = startPos.y
		vert.z = startPos.z + (unitVert.z * CYLINDER_RADIUS)
		topFaceVerts.push_back(vert)
		
	# build bottom face vertices
	var bottomFaceVerts = []
	for sliceNum in range(CYLINDER_SLICES + 1):
		var unitVert = unitCircleVertices[sliceNum]
		var vert : Vector3
		vert.x = endPos.x + (unitVert.x * CYLINDER_RADIUS)
		vert.y = endPos.y
		vert.z = endPos.z + (unitVert.z * CYLINDER_RADIUS)
		bottomFaceVerts.push_back(vert)
	
	
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
	add_vertex(startPos) # center vert
	for sliceNum in range(CYLINDER_SLICES + 1):
		var vert = topFaceVerts[sliceNum]
		add_vertex(vert)
	end()
	
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
	add_vertex(endPos) # center vert
	for sliceNum in range(CYLINDER_SLICES + 1):
		var vert = bottomFaceVerts[CYLINDER_SLICES - sliceNum]
		add_vertex(vert)
	end()

	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# draw connecting sectors between top and bottom face verts
	for sliceNum in range(CYLINDER_SLICES):
		var nextSliceNum = (sliceNum + 1) % CYLINDER_SLICES
		
		var sliceTopVert = topFaceVerts[sliceNum]
		var sliceBottomVert = bottomFaceVerts[sliceNum]
		
		var nextSliceTopVert = topFaceVerts[nextSliceNum]
		var nextSliceBottomVert = bottomFaceVerts[nextSliceNum]
		
		var unitVert = unitCircleVertices[sliceNum]
		var nextUnitVert = unitCircleVertices[nextSliceNum]
		
		var normalVert = (unitVert + nextUnitVert) / 2
		
		# tri 1
		add_vertex(sliceTopVert)
		add_vertex(sliceBottomVert)
		add_vertex(nextSliceTopVert)
		
		# tri 2
		add_vertex(nextSliceTopVert)
		add_vertex(sliceBottomVert)
		add_vertex(nextSliceBottomVert)
	end()
