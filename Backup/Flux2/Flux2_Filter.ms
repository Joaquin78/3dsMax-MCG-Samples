plugin simpleMeshMod Flux2_Filter
	name:"Flux2_Filter"
	classID:#(0x5CC95D43, 0x238CD282)
	category:"Max Creation Graph"
	usePBValidity:true
(
	local pluginDefinitionFile -- the plugin definition file
	local pluginInstance -- the plugin instance created from the plugin definition
	local _meshWrapper -- the dotnet wrapper around the stack mesh pointer
	local argsType = dotNetClass "System.Object[]" -- used when creating args array
	local dotnet_ValueToDotNetObject = dotnet.ValueToDotNetObject
	local tmHandler
	--simulation locals
	local _lastTime = 0.0
	local interactiveMode = false

	-- function wrappers
	local _meshWrapper_SetValue
	local pluginInstance_UpdateMesh

	-- value wrapper local and function wrapper declarations
	local meshWrapper, meshWrapper_SetValue


	parameters main rollout:params
	(
		filter_by_angle ui:filter_by_angle default:False type:#boolean animatable:true
		flux_channel ui:flux_channel default:2 type:#integer animatable:true
		invert_angle_filter ui:invert_angle_filter default:False type:#boolean animatable:true
		horizontal_or_Z_axis ui:horizontal_or_Z_axis default:True type:#boolean animatable:true
		max_angle ui:max_angle default:180 type:#float animatable:true
		filter_by_box ui:filter_by_box default:False type:#boolean animatable:true
		invert_box_filter ui:invert_box_filter default:False type:#boolean animatable:true
		box_component ui:box_component default:0 type:#integer animatable:true
		box_min_or_max ui:box_min_or_max default:0 type:#integer animatable:true
		box_distance ui:box_distance default:10 type:#float animatable:true
		probability ui:probability default:50 type:#float animatable:true
		seed ui:seed default:0 type:#integer animatable:true
		create_mesh ui:create_mesh default:False type:#boolean animatable:true
		box_size ui:box_size default:1 type:#float animatable:true
		_dummy type:#boolean -- this exists to enable easy invalidation of the object
		pluginGraph type:#filename assettype:#MaxCreationGraph readOnly:true enumAsAsset:true 
		pluginGraphDependencies type:#filenametab assettype:#MaxCreationGraph readOnly:true enumAsAsset:true tabSize:0 tabSizeVariable:true
	)



	fn RunSimLoop updateFxn = (
		local result = ok
		try (
			result = updateFxn ()
		)
		catch()
		return result
	)

	fn initialize = 
	(
		pluginDefinitionFile = @"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\Flux2_Filter.maxtool"
		local c = dotNetClass "Viper3dsMaxBridge.ModifierPluginInstance"
		local cid = this.classId
		local refMakerWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.ReferenceMaker"
		refMakerWrapper = refMakerWrapperClass._CreateWrapper this
		pluginInstance = c.CreateInstance cid[1] cid[2] pluginDefinitionFile refMakerWrapper
		pluginInstance_UpdateMesh = pluginInstance.UpdateMesh
		local meshWrapperClass = dotnetclass "Autodesk.Max.MaxPlus.Mesh"
		_meshWrapper = meshWrapperClass._CreateWrapper undefined
		_meshWrapper_SetValue = _meshWrapper._SetValue
		pluginGraph = pluginDefinitionFile
		pluginGraphDependencies = #(@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxFilterByAngle.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\XOr.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorAngleFromHorizontalPlaneOrZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorAngleFromZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorAngleFromAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\AngleDistanceFromPi.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FloatModuloDistance.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Lesser.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorAngleFromHorizontalPlane.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorPlaneAngle.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\ComplementaryAngle.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\HorizontalPlane.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\PlaneAtOrigin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\RayFromOrigin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixZAxis.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Slices.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixFromRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\SetMatrixFrom3Rows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Three.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\PlusOne.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\StoreMatricesInMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatrixRows.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\FlatMap.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxFilterByBox.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\DivideBy100.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorBoxComponentDistanceAsRatio.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorBoxComponentDistance.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorBoxMaxComponentDistance.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorComponentDistance.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorComponent.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\VectorAsArray.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Array3.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorBoxMinComponentDistance.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoundingBoxExtent.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\DivideDefaultToZero.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\DivideDefault.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FloatIsSmall.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\VectorLengthEpsilon.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxBoundingBox.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\FluxGetPositions.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MatricesFromMapChannel.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxFilterRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\AU\compounds\FilterRandomly.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Tools\Flux2\FluxMeshAsBoxes.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\TransformMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\DeformMeshPoints.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxFromPointAndRadius.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\Origin.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\BoxTriMesh.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\HideEveryThirdEdge.maxcompound",@"C:\Program Files\Autodesk\3ds Max 2017\MaxCreationGraph\Compounds\ModuloEquals.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MeshCopyCustomMapChannelVertexBuffers.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelCopyVertexBuffer.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\MapChannelExists.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\IsNullFix2.maxcompound",@"C:\Users\digginc\Autodesk\3ds Max 2017\Max Creation Graph\Compounds\GetMapChannelOrGeometry.maxcompound")

		-- value wrapper local initializations
		local meshWrapperClass = dotNetClass "Autodesk.Max.MaxPlus.Mesh"
		meshWrapper = meshWrapperClass._CreateWrapper (undefined)
		meshWrapper_SetValue = meshWrapper._SetValue

	)

	on create do 
	(
		initialize()
	)

	on clone fromObj do 
	(
		initialize()
	)

	on load do 
	(
		initialize()
	)

	on update do 
	(
		initialize()
	)

	rollout params "Parameters"
	(
		checkbox filter_by_angle "filter by angle" checked:False
		spinner flux_channel "flux channel" range:[-3, 101, 2] type:#integer
		checkbox invert_angle_filter "invert angle filter" checked:False
		checkbox horizontal_or_Z_axis "horizontal or Z axis" checked:True
		spinner max_angle "max angle" range:[-360, 360, 180] type:#float
		checkbox filter_by_box "filter by box" checked:False
		checkbox invert_box_filter "invert box filter" checked:False
		spinner box_component "box component" range:[0, 2, 0] type:#integer
		spinner box_min_or_max "box min or max" range:[0, 2, 0] type:#integer
		spinner box_distance "box distance" range:[0, 100, 10] type:#float
		spinner probability "probability" range:[0, 100, 50] type:#float
		spinner seed "seed" range:[0, 10000, 0] type:#integer
		checkbox create_mesh "create mesh" checked:False
		spinner box_size "box size" range:[0, 100000, 1] type:#float

	)




	fn updateMesh = 
	(

		if (pluginInstance == undefined) then ( return undefined )
		local args = dotnet_ValueToDotNetObject #(meshWrapper, filter_by_angle, flux_channel, invert_angle_filter, horizontal_or_Z_axis, max_angle, filter_by_box, invert_box_filter, box_component, box_min_or_max, box_distance, probability, seed, create_mesh, box_size) argsType
		pluginInstance_UpdateMesh (currentTime as integer) _meshWrapper args
		ok
	)
	
	on modifyMesh do
	(
		_meshWrapper_SetValue mesh
		meshWrapper_SetValue mesh

		if (PreInvokeMethod != undefined ) then PreInvokeMethod()
		RunSimLoop updateMesh
		_meshWrapper_SetValue undefined

		if (PostInvokeMethod != undefined ) then PostInvokeMethod()
		ok
	)

)