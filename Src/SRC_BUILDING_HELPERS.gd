extends Node
class_name BuildingHelpers

static var CheckPositions = [Vector3(1,0,1),Vector3(0,0,1),Vector3(-1,0,1),
							Vector3(1,0,0),Vector3(0,0,0),Vector3(-1,0,0),
							Vector3(1,0,-1),Vector3(0,0,-1),Vector3(-1,0,-1)]

func CheckBorderingGridAverage(_position:Vector3,CornerFix:bool = false) -> Vector3:
	var EmptyPoints:Array[Vector3]
	var val:Vector3
	var avg:Vector3
	for i in CheckPositions.size():
		if BuildingPoints.has(_position + CheckPositions[i]):
			EmptyPoints.append( (CheckPositions[i]) )
			
	for i in EmptyPoints.size():
		val += EmptyPoints[i]
		
	avg = val / EmptyPoints.size()
	if CornerFix:
		return (avg*5).round()
	return avg.round()
	

func CheckBorderingGridCorners(_position:Vector3,_snap:bool = true) -> Vector3:
	var val:Vector3
	var avg:Vector3
	var FoundCorners:Array[Vector3]
	
	var dir:Vector3
	
	for i in CheckPositions.size():
		if BuildingPoints.has(_position + CheckPositions[i]) and !PERMANENTPLACEMENTS.has(_position + CheckPositions[i]):
			FoundCorners.append(CheckPositions[i])

	if FoundCorners.is_empty():
		#print("NO CORNERS FOUND")
		return Vector3.ZERO
		
	var sum = FoundCorners.reduce(func(acc, num): return acc + num)
	var average:Vector3 = sum / FoundCorners.size()*1
	
	
	#print("RETURNING CORNER VALUE OF :: " + str(average))
	return average.snappedf(0.1) if _snap else average

func GetAverageWallRotationIndex(_position:Vector3,CornerFix:bool = false,_offset:Vector3 = Vector3.ZERO,intcheck:int = -1) -> int:
	var checking:Vector3 = CheckBorderingGridAverage(_position,CornerFix) + _offset
	var CornerChecking = CheckBorderingGridCorners(_position,true)
	if CornerFix:
		match CornerChecking:
			Vector3(-1,0,-1),Vector3(Vector3.FORWARD),Vector3(1,0,-1),Vector3(Vector3.LEFT),Vector3(Vector3.RIGHT),Vector3(Vector3(-1,0,1)),Vector3(Vector3.BACK),Vector3(1,0,1):
				#print("KORNA " + str(CornerChecking))
				match checking:
					Vector3(-1,0,-1):
						return 22
					Vector3(-1.0,0.0,1.0):
						return 0
					Vector3(1,0,-1):
						return 10
					Vector3(1.0,0,1.0):
						return 16
					Vector3(0.0,0,-1.0):
						return 6
					Vector3(0,1,0),Vector3(-1.0,0.0,-1.0):
						return 10
					Vector3(1.0,0,-0.5),Vector3(1.0,0,0.5):
						return 16
					Vector3(1,0,1):
						return 22
					Vector3(-1,0,0.5),Vector3(-1,0,-0.5):
						return 22
					Vector3(0.5,0,-1):
						return 10
					
			_:
				#print("OTHA KORNA " + str(CornerChecking))
				match CornerChecking:
					
					Vector3(-0.5,0,0.5):
						return 10
					
					Vector3(-0.5,0,-0.5):
						return 16
										
					Vector3(0.5,0,0.5):
						return 22
					
					Vector3(0.2,0,0.6):
						return 22
					
					Vector3(-0.1,0,0.3):
						return 10
					Vector3(-0.3,0,0.1),Vector3(-0.3,0,-0.1):
						return 16
					Vector3(0.3,0,0.1):
						return 22
					Vector3(0.1,0,0.3):
						return 10
					Vector3(0.3,0,-0.1):
						return 22
						
					Vector3(-0.1, 0.0, -0.1):
						#print("RETURNING 7S")
						return 22
					Vector3(0.1, 0.0, 0.1):
						#print("RETURNING 7S")
						return 16
					
					Vector3(-0.5,0,0):
						return 16
					Vector3(0.5,0,0):
						return 22
					Vector3(0,0,0.5):
						return 10
						
					Vector3(0.1, 0.0, -0.1):
						#print("RETURNING 7S")
						return 10
					Vector3(0.0, 0.0, 0.1):
						#print("RETURNING 7S")
						return 10
					
					##4
					Vector3(0.6, 0.0, 0.2):
						#print("RETURNING 7S")
						return 22
					Vector3(-0.6, 0.0, -0.2):
						#print("RETURNING 7S")
						return 16
					Vector3(-0.6, 0.0, 0.2):
						#print("RETURNING 7S")
						return 10
					Vector3(-0.2, 0.0, -0.6):
						#print("RETURNING 7S")
						return 16
					Vector3(-0.2, 0.0, 0.6):
						#print("RETURNING 7S")
						return 10
					
	else:
		#print("FINAL KORNAS " + str(checking))
		match checking:
			Vector3.FORWARD:
				return 0
			Vector3.BACK:
				return 10
			Vector3.LEFT:
				return 16
			Vector3.RIGHT:
				return 22
		if intcheck == 7:
			#print("OH MY GOODNESS ITS 7" + str(CornerChecking))
			match CornerChecking:
				pass
	return 0

func CellRotationToEuler(_value:int) -> Vector3:
	#print("CHECKING ::" + str(_value))
	match _value:
		0:
			return Vector3(0,0,0)
		10:
			return Vector3(0,180,0)
		16:
			return Vector3(0,90,0)
		22:
			return Vector3(0,255,0)
		_:
			return Vector3(0,0,0)
	pass
