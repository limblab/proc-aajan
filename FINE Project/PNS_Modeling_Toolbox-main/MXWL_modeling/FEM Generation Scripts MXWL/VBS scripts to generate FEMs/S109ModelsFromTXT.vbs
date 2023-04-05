' ----------------------------------------------
' Script Recorded by Ansoft Maxwell Version 14.0.0
' 1:52:39 PM  Jul 19, 2016
' ----------------------------------------------

'MEDIAN NERVE (13 Fascicles) WITH OR WITHOUT ENCAPSULATION
'Just Change directory name to Encapsulation or No Encapsulation (and adjust file names accordingly
'VARIABLES TO CHANGE
ModelNameShort = "S109 M7F39 NE 16CwAS CFINE C"
ModelName = "E:\ICNerveModels\S109_Median7Frame39Modeling\No Encapsulation\" & ModelNameShort
FascCoordsFileName = "E:\ICNerveModels\S109_Median7Frame39Modeling\No Encapsulation\M7T39_NoEncap_fasccoords.txt"
VoutFileName = "E:\ICNerveModels\S109_Median7Frame39Modeling\No Encapsulation\M7T39_NoEncap_Vout"
NumFascicles = 13
encapsulation_thickness = 0'0.25

Dim oAnsoftApp
Dim oDesktop
Dim oProject
Dim oDesign
Dim oEditor
Dim oModule
Set oAnsoftApp = CreateObject("AnsoftMaxwell.MaxwellScriptInterface")
Set oDesktop = oAnsoftApp.GetAppDesktop()
oDesktop.RestoreWindow

'for every contact
for contact_number = 1 to 15
	'Create Nerve in CFINE
	oDesktop.OpenProject "E:\ICNerveModels\16 channel with anode strip CFINE_10x1.mxwl"
	Set oProject = oDesktop.SetActiveProject("16 channel with anode strip CFINE_10x1")

	oProject.SaveAs ModelName & contact_number & ".mxwl", true

	Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
	Set oEditor = oDesign.SetActiveEditor("3D Modeler")

	Set oDefinitionManager = oProject.GetDefinitionManager()
	'material properties
	oDefinitionManager.AddMaterial Array("NAME:Endoneurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), Array("NAME:conductivity", "property_type:=", "AnisoProperty", "unit:=", "", "component1:=", "0.0826", "component2:=", "0.0826", "component3:=", "0.571"))
	oDefinitionManager.AddMaterial Array("NAME:Epineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.0826")
	oDefinitionManager.AddMaterial Array("NAME:Perineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.00088")
	oDefinitionManager.AddMaterial Array("NAME:Encapsulation", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.1")
	oDefinitionManager.AddMaterial Array("NAME:Saline", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "permittivity:=", "81", "conductivity:=", "2")
	
	'set saline
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "SalineMedium"), Array("NAME:ChangedProps", Array("NAME:Material", "Value:=", "" & Chr(34) & "Saline" & Chr(34) & ""))))

	Set objFileToRead = CreateObject("Scripting.FileSystemObject").OpenTextFile(FascCoordsFileName,1)
	do while not objFileToRead.AtEndOfStream
		for fascicle_number = 1 to NumFascicles
			EndoX = objFileToRead.ReadLine()
			EndoY = objFileToRead.ReadLine()
			EndoR = objFileToRead.ReadLine()
			PeriX = objFileToRead.ReadLine()
			PeriY = objFileToRead.ReadLine()
			PeriR = objFileToRead.ReadLine()
			
			'NO manual shifts to eliminate fascicle intersections with epineurium needed'
			
			'Endo
			'Project Variables
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "R", "Value:=", (EndoR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "X", "Value:=", (EndoX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoY & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "Y", "Value:=", (EndoY & "mm")))))
 			'Create
			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Endo" & fascicle_number, "Flags:=", "", "Color:=", "(255 128 128)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Endoneurium" & Chr(34) & "", "SolveInside:=", true)
			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Endo" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Endo" & fascicle_number & "X", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Endo" & fascicle_number & "X+$Endo" & fascicle_number & "R", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"))))
			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Endo" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
			
			'Peri
			'Project Variables
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "R", "Value:=", (PeriR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "X", "Value:=", (PeriX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriY & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "Y", "Value:=", (PeriY & "mm")))))
 			'Create
			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Peri" & fascicle_number, "Flags:=", "", "Color:=", "(255 62 62)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Perineurium" & Chr(34) & "", "SolveInside:=", true)
			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Peri" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Peri" & fascicle_number & "X", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Peri" & fascicle_number & "X+$Peri" & fascicle_number & "R", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"))))
			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Peri" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
		next
	loop
	'Epi
	oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$encapsulation_thickness", "Value:=", encapsulation_thickness & "mm"))))
	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "0mm", "YPosition:=", "0mm", "ZPosition:=", "0mm", "XSize:=", "1mm", "YSize:=", "1mm", "ZSize:=", "1mm"), Array("NAME:Attributes", "Name:=", "Epineurium", "Flags:=", "", "Color:=", "(255 234 234)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Epineurium" & Chr(34) & "", "SolveInside:=", true)
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Epineurium:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_inner/2 + $encapsulation_thickness", "Y:=", "-$cuff_height_inner/2 + $encapsulation_thickness", "Z:=", "-25mm"), Array("NAME:XSize", "Value:=", "$cuff_length_inner - 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_inner - 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "10mm"))))
	oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Epineurium", "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)

	objFileToRead.Close
   Set objFileToRead = Nothing
	
	'Encapsulation
	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "-2.5mm", "YPosition:=", "2mm", "ZPosition:=", "0mm", "XSize:=", "0.5mm", "YSize:=", "-0.5mm", "ZSize:=", "-9.5mm"), Array("NAME:Attributes", "Name:=", "Encapsulation", "Flags:=", "", "Color:=", "(255 255 198)", "Transparency:=", 0.6, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Encapsulation" & Chr(34) & "", "SolveInside:=", true)
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Encapsulation:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_outer/2 - $encapsulation_thickness", "Y:=", "-$cuff_height_outer/2 - $encapsulation_thickness", "Z:=", "-$cuff_width/2 - $encapsulation_thickness"), Array("NAME:XSize", "Value:=", "$cuff_length_outer + 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_outer + 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "$cuff_width + 2*$encapsulation_thickness"))))
	oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Encapsulation", "Tool Parts:=", "Epineurium_1,Epineurium_2,Epineurium_3"), Array("NAME:SubtractParameters", "KeepOriginals:=", true)

	'Define which contact are running model of
	Set oModule = oDesign.GetModule("BoundarySetup")
	for other_contacts = 1 to 15
		if other_contacts <> contact_number then
			oModule.DeleteBoundaries Array("Current" & other_contacts)
		end if
	next
	oProject.Save

   'Analyze Model
	oDesign.AnalyzeAll
   'Save and Close
	oProject.Save
	oDesktop.CloseProject ModelNameShort & contact_number
next









'MEDIAN NERVE (10 fascicles) WITH OR WITHOUT ENCAPSULATION
'Just Change directory name to Encapsulation or No Encapsulation (and adjust file names accordingly
'VARIABLES TO CHANGE
ModelNameShort = "S109 M1F193 NE 16CwAS CFINE C"
ModelName = "E:\ICNerveModels\S109_Median1Frame193Modeling\NoEncapsulation\" & ModelNameShort
FascCoordsFileName = "E:\ICNerveModels\S109_Median1Frame193Modeling\NoEncapsulation\M1T193_NoEncap_fasccoords.txt"
VoutFileName = "E:\ICNerveModels\S109_Median1Frame193Modeling\NoEncapsulation\M1T193_NoEncap_Vout"
NumFascicles = 10
encapsulation_thickness = 0 '0.25

'for every contact
for contact_number = 1 to 15
	'Create Nerve in CFINE
	oDesktop.OpenProject "E:\ICNerveModels\16 channel with anode strip CFINE_10x1.mxwl"
	Set oProject = oDesktop.SetActiveProject("16 channel with anode strip CFINE_10x1")

	oProject.SaveAs ModelName & contact_number & ".mxwl", true

	Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
	Set oEditor = oDesign.SetActiveEditor("3D Modeler")

	Set oDefinitionManager = oProject.GetDefinitionManager()
	'material properties
	oDefinitionManager.AddMaterial Array("NAME:Endoneurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), Array("NAME:conductivity", "property_type:=", "AnisoProperty", "unit:=", "", "component1:=", "0.0826", "component2:=", "0.0826", "component3:=", "0.571"))
	oDefinitionManager.AddMaterial Array("NAME:Epineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.0826")
	oDefinitionManager.AddMaterial Array("NAME:Perineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.00088")
	oDefinitionManager.AddMaterial Array("NAME:Encapsulation", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.1")
	oDefinitionManager.AddMaterial Array("NAME:Saline", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "permittivity:=", "81", "conductivity:=", "2")
	
	'set saline
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "SalineMedium"), Array("NAME:ChangedProps", Array("NAME:Material", "Value:=", "" & Chr(34) & "Saline" & Chr(34) & ""))))

	Set objFileToRead = CreateObject("Scripting.FileSystemObject").OpenTextFile(FascCoordsFileName,1)
	do while not objFileToRead.AtEndOfStream
		for fascicle_number = 1 to NumFascicles
			EndoX = objFileToRead.ReadLine()
			EndoY = objFileToRead.ReadLine()
			EndoR = objFileToRead.ReadLine()
			PeriX = objFileToRead.ReadLine()
			PeriY = objFileToRead.ReadLine()
			PeriR = objFileToRead.ReadLine()
			
			'no manual shifts to eliminate fascicle intersections with epineurium necessary'
			
			'Endo
			'Project Variables
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "R", "Value:=", (EndoR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "X", "Value:=", (EndoX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoY & "mm")))))
 			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "Y", "Value:=", (EndoY & "mm")))))
 			'Create
			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Endo" & fascicle_number, "Flags:=", "", "Color:=", "(255 128 128)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Endoneurium" & Chr(34) & "", "SolveInside:=", true)
			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Endo" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Endo" & fascicle_number & "X", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Endo" & fascicle_number & "X+$Endo" & fascicle_number & "R", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"))))
			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Endo" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
			
			'Peri
			'Project Variables
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "R", "Value:=", (PeriR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "X", "Value:=", (PeriX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriY & "mm")))))
 			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "Y", "Value:=", (PeriY & "mm")))))
 			'Create
			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Peri" & fascicle_number, "Flags:=", "", "Color:=", "(255 62 62)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Perineurium" & Chr(34) & "", "SolveInside:=", true)
			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Peri" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Peri" & fascicle_number & "X", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Peri" & fascicle_number & "X+$Peri" & fascicle_number & "R", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"))))
			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Peri" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
		next
	loop
	'Epi
	oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$encapsulation_thickness", "Value:=", encapsulation_thickness & "mm"))))
	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "0mm", "YPosition:=", "0mm", "ZPosition:=", "0mm", "XSize:=", "1mm", "YSize:=", "1mm", "ZSize:=", "1mm"), Array("NAME:Attributes", "Name:=", "Epineurium", "Flags:=", "", "Color:=", "(255 234 234)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Epineurium" & Chr(34) & "", "SolveInside:=", true)
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Epineurium:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_inner/2 + $encapsulation_thickness", "Y:=", "-$cuff_height_inner/2 + $encapsulation_thickness", "Z:=", "-25mm"), Array("NAME:XSize", "Value:=", "$cuff_length_inner - 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_inner - 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "10mm"))))
	oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Epineurium", "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)

	objFileToRead.Close
   Set objFileToRead = Nothing
	'Encapsulation 
	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "-2.5mm", "YPosition:=", "2mm", "ZPosition:=", "0mm", "XSize:=", "0.5mm", "YSize:=", "-0.5mm", "ZSize:=", "-9.5mm"), Array("NAME:Attributes", "Name:=", "Encapsulation", "Flags:=", "", "Color:=", "(255 255 198)", "Transparency:=", 0.6, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Encapsulation" & Chr(34) & "", "SolveInside:=", true)
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Encapsulation:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_outer/2 - $encapsulation_thickness", "Y:=", "-$cuff_height_outer/2 - $encapsulation_thickness", "Z:=", "-$cuff_width/2 - $encapsulation_thickness"), Array("NAME:XSize", "Value:=", "$cuff_length_outer + 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_outer + 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "$cuff_width + 2*$encapsulation_thickness"))))
	oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Encapsulation", "Tool Parts:=", "Epineurium_1,Epineurium_2,Epineurium_3"), Array("NAME:SubtractParameters", "KeepOriginals:=", true)

	'Define which contact are running model of
	Set oModule = oDesign.GetModule("BoundarySetup")
	for other_contacts = 1 to 15
		if other_contacts <> contact_number then
			oModule.DeleteBoundaries Array("Current" & other_contacts)
		end if
	next
	oProject.Save

	'Analyze Model
	oDesign.AnalyzeAll
	'Save and Close
	oProject.Save
	oDesktop.CloseProject ModelNameShort & contact_number
next










'ULNAR NERVE (6 fascicles) WITHOUT ENCAPSULATION
'VARIABLES TO CHANGE
ModelNameShort = "S109 M9F19 NE 16CwAS CFINE C"
ModelName = "E:\ICNerveModels\S109_Ulnar9Frame19Modeling\No Encapsulation\" & ModelNameShort
FascCoordsFileName = "E:\ICNerveModels\S109_Ulnar9Frame19Modeling\No Encapsulation\U9T19_NoEncap_fasccoord.txt"
VoutFileName = "E:\ICNerveModels\S109_Ulnar9Frame19Modeling\No Encapsulation\U9T19_NoEncap_Vout"
NumFascicles = 6
encapsulation_thickness = 0 '0.25

'for every contact
for contact_number = 1 to 15
	'Create Nerve in CFINE
	oDesktop.OpenProject "E:\ICNerveModels\16 channel with anode strip CFINE_10x1.mxwl"
	Set oProject = oDesktop.SetActiveProject("16 channel with anode strip CFINE_10x1")

	oProject.SaveAs ModelName & contact_number & ".mxwl", true

	Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
	Set oEditor = oDesign.SetActiveEditor("3D Modeler")

	Set oDefinitionManager = oProject.GetDefinitionManager()
	'material properties
	oDefinitionManager.AddMaterial Array("NAME:Endoneurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), Array("NAME:conductivity", "property_type:=", "AnisoProperty", "unit:=", "", "component1:=", "0.0826", "component2:=", "0.0826", "component3:=", "0.571"))
	oDefinitionManager.AddMaterial Array("NAME:Epineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.0826")
	oDefinitionManager.AddMaterial Array("NAME:Perineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.00088")
	oDefinitionManager.AddMaterial Array("NAME:Encapsulation", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.1")
	oDefinitionManager.AddMaterial Array("NAME:Saline", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "permittivity:=", "81", "conductivity:=", "2")
	
	'set saline
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "SalineMedium"), Array("NAME:ChangedProps", Array("NAME:Material", "Value:=", "" & Chr(34) & "Saline" & Chr(34) & ""))))

	Set objFileToRead = CreateObject("Scripting.FileSystemObject").OpenTextFile(FascCoordsFileName,1)
	do while not objFileToRead.AtEndOfStream
		for fascicle_number = 1 to NumFascicles
			EndoX = objFileToRead.ReadLine()
			EndoY = objFileToRead.ReadLine()
			EndoR = objFileToRead.ReadLine()
			PeriX = objFileToRead.ReadLine()
			PeriY = objFileToRead.ReadLine()
			PeriR = objFileToRead.ReadLine()
			
			'add any manual shifts to eliminate fascicle intersections with epineurium'
			'x shifts are to account for recruitment order observed in experimental data
			if fascicle_number = 2 then
				EndoX=EndoX-1.0
				PeriX=PeriX-1.0
			end if
			if fascicle_number = 1 then
				EndoX=EndoX-0.7
				PeriX=PeriX-0.7
			end if
			if fascicle_number = 3 then
				EndoX=EndoX+1.2
				PeriX=PeriX+1.2
			end if
			if fascicle_number = 4 then
				EndoX=EndoX+1.2
				PeriX=PeriX+1.2
			end if
			if fascicle_number = 5 then
				EndoX=EndoX+1.2
				PeriX=PeriX+1.2
			end if
			if fascicle_number = 6 then
				EndoX=EndoX+1.2
				PeriX=PeriX+1.2
			end if

			'Endo
			'Project Variables
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "R", "Value:=", (EndoR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "X", "Value:=", (EndoX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoY & "mm")))))
 			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "Y", "Value:=", (EndoY & "mm")))))
 			'Create
			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Endo" & fascicle_number, "Flags:=", "", "Color:=", "(255 128 128)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Endoneurium" & Chr(34) & "", "SolveInside:=", true)
			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Endo" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Endo" & fascicle_number & "X", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Endo" & fascicle_number & "X+$Endo" & fascicle_number & "R", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"))))
			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Endo" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
			
			'Peri
			'Project Variables
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "R", "Value:=", (PeriR & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "X", "Value:=", (PeriX & "mm")))))
			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriY & "mm")))))
 			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "Y", "Value:=", (PeriY & "mm")))))
 			'Create
			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Peri" & fascicle_number, "Flags:=", "", "Color:=", "(255 62 62)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Perineurium" & Chr(34) & "", "SolveInside:=", true)
			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Peri" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Peri" & fascicle_number & "X", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Peri" & fascicle_number & "X+$Peri" & fascicle_number & "R", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"))))
			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Peri" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
		next
	loop
	'Epi
	oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$encapsulation_thickness", "Value:=", encapsulation_thickness & "mm"))))
	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "0mm", "YPosition:=", "0mm", "ZPosition:=", "0mm", "XSize:=", "1mm", "YSize:=", "1mm", "ZSize:=", "1mm"), Array("NAME:Attributes", "Name:=", "Epineurium", "Flags:=", "", "Color:=", "(255 234 234)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Epineurium" & Chr(34) & "", "SolveInside:=", true)
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Epineurium:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_inner/2 + $encapsulation_thickness", "Y:=", "-$cuff_height_inner/2 + $encapsulation_thickness", "Z:=", "-25mm"), Array("NAME:XSize", "Value:=", "$cuff_length_inner - 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_inner - 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "10mm"))))
	oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Epineurium", "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)

	objFileToRead.Close
    Set objFileToRead = Nothing
	
	'Encapsulation
	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "-2.5mm", "YPosition:=", "2mm", "ZPosition:=", "0mm", "XSize:=", "0.5mm", "YSize:=", "-0.5mm", "ZSize:=", "-9.5mm"), Array("NAME:Attributes", "Name:=", "Encapsulation", "Flags:=", "", "Color:=", "(255 255 198)", "Transparency:=", 0.6, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Encapsulation" & Chr(34) & "", "SolveInside:=", true)
	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Encapsulation:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_outer/2 - $encapsulation_thickness", "Y:=", "-$cuff_height_outer/2 - $encapsulation_thickness", "Z:=", "-$cuff_width/2 - $encapsulation_thickness"), Array("NAME:XSize", "Value:=", "$cuff_length_outer + 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_outer + 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "$cuff_width + 2*$encapsulation_thickness"))))
	oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Encapsulation", "Tool Parts:=", "Epineurium_1,Epineurium_2,Epineurium_3"), Array("NAME:SubtractParameters", "KeepOriginals:=", true)

	'Define which contact are running model of
	Set oModule = oDesign.GetModule("BoundarySetup")
	for other_contacts = 1 to 15
		if other_contacts <> contact_number then
			oModule.DeleteBoundaries Array("Current" & other_contacts)
		end if
	next
	oProject.Save

	'oModule.EditSetup "Setup1", Array("NAME:Setup1", "Enabled:=", true, "MaximumPasses:=", 3, "MinimumPasses:=", 2, "MinimumConvergedPasses:=", 1, "PercentRefinement:=", 30, "SolveFieldOnly:=", false, "PercentError:=", 1, "SolveMatrixAtLast:=", true, "PercentError:=", 1, "UseIterativeSolver:=", false, "RelativeResidual:=", 1E-006, "ComputePowerLoss:=", false, "ThermalFeedback:=", false)
	'Analyze Model
	oDesign.AnalyzeAll
  'Save and Close
	oProject.Save
	oDesktop.CloseProject ModelNameShort & contact_number
next



''ULNAR NERVE (6 fascicles) WITH ENCAPSULATION
''VARIABLES TO CHANGE
'ModelNameShort = "S109 M9F19 E 16CwAS CFINE C"
'ModelName = "E:\ICNerveModels\S109_Ulnar9Frame19Modeling\Encapsulation\" & ModelNameShort
'FascCoordsFileName = "E:\ICNerveModels\S109_Ulnar9Frame19Modeling\Encapsulation\U9T19_Encap_fasccoord.txt"
'VoutFileName = "E:\ICNerveModels\S109_Ulnar9Frame19Modeling\Encapsulation\U9T19_Encap_Vout"
'NumFascicles = 6
'encapsulation_thickness = 0 '0.25

'for every contact
'for contact_number = 1 to 15
'	'Create Nerve in CFINE
'	oDesktop.OpenProject "E:\ICNerveModels\16 channel with anode strip CFINE_10x1.mxwl"
'	Set oProject = oDesktop.SetActiveProject("16 channel with anode strip CFINE_10x1")
'
'	oProject.SaveAs ModelName & contact_number & ".mxwl", true
'
'	Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
'	Set oEditor = oDesign.SetActiveEditor("3D Modeler")
'
'	Set oDefinitionManager = oProject.GetDefinitionManager()
'	'material properties
'	oDefinitionManager.AddMaterial Array("NAME:Endoneurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), Array("NAME:conductivity", "property_type:=", "AnisoProperty", "unit:=", "", "component1:=", "0.0826", "component2:=", "0.0826", "component3:=", "0.571"))
'	oDefinitionManager.AddMaterial Array("NAME:Epineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.0826")
'	oDefinitionManager.AddMaterial Array("NAME:Perineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.00088")
'	oDefinitionManager.AddMaterial Array("NAME:Encapsulation", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.1")
'	oDefinitionManager.AddMaterial Array("NAME:Saline", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "permittivity:=", "81", "conductivity:=", "2")
'	
'	'set saline
'	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "SalineMedium"), Array("NAME:ChangedProps", Array("NAME:Material", "Value:=", "" & Chr(34) & "Saline" & Chr(34) & ""))))
'
'	Set objFileToRead = CreateObject("Scripting.FileSystemObject").OpenTextFile(FascCoordsFileName,1)
'	do while not objFileToRead.AtEndOfStream
'		for fascicle_number = 1 to NumFascicles
'			EndoX = objFileToRead.ReadLine()
'			EndoY = objFileToRead.ReadLine()
'			EndoR = objFileToRead.ReadLine()
'			PeriX = objFileToRead.ReadLine()
'			PeriY = objFileToRead.ReadLine()
'			PeriR = objFileToRead.ReadLine()
'			
'			'add any manual shifts to eliminate fascicle intersections with epineurium'
'			'x shifts are to account for recruitment order observed in experimental data
'			if fascicle_number = 2 then
'				EndoX=EndoX-0.6
'				PeriX=PeriX-0.6
'				EndoY=EndoY-0.193485926361825
'				PeriY=PeriY-0.193485926361825
'			end if
'			if fascicle_number = 1 then
'				EndoX=EndoX-0.45
'				PeriX=PeriX-0.45
'				EndoY=EndoY+0.223607490210831
'				PeriY=PeriY+0.223607490210831
'			end if
'			if fascicle_number = 3 then
'				EndoX=EndoX+1.5
'				PeriX=PeriX+1.5
'			end if
'			if fascicle_number = 4 then
'				EndoX=EndoX+1.5
'				PeriX=PeriX+1.5
'				EndoY=EndoY-0.264742673844086
'				PeriY=PeriY-0.264742673844086
'			end if
'			if fascicle_number = 5 then
'				EndoX=EndoX+1.5
'				PeriX=PeriX+1.5
'				EndoY=EndoY+0.140800949005192
'				PeriY=PeriY+0.140800949005192
'			end if
'			if fascicle_number = 6 then
'				EndoX=EndoX+1.5
'				PeriX=PeriX+1.5
'			end if
'
'			'Endo
'			'Project Variables
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoR & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "R", "Value:=", (EndoR & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoX & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "X", "Value:=", (EndoX & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Endo" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (EndoY & "mm")))))
' 			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Endo" & fascicle_number & "Y", "Value:=", (EndoY & "mm")))))
' 			'Create
'			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Endo" & fascicle_number, "Flags:=", "", "Color:=", "(255 128 128)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Endoneurium" & Chr(34) & "", "SolveInside:=", true)
'			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Endo" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Endo" & fascicle_number & "X", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Endo" & fascicle_number & "X+$Endo" & fascicle_number & "R", "Y:=", "$Endo" & fascicle_number & "Y", "Z:=", "-25mm"))))
'			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Endo" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
'			
'			'Peri
'			'Project Variables
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "R", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriR & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "R", "Value:=", (PeriR & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "X", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriX & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "X", "Value:=", (PeriX & "mm")))))
'			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:NewProps", Array("NAME:$Peri" & fascicle_number & "Y", "PropType:=", "VariableProp", "UserDef:=", true, "Value:=", (PeriY & "mm")))))
' 			oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$Peri" & fascicle_number & "Y", "Value:=", (PeriY & "mm")))))
' 			'Create
'			oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "XCenter:=", "0mm", "YCenter:=", "0mm", "ZCenter:=", "0mm", "XStart:=", "1mm", "YStart:=", "0mm", "ZStart:=", "0mm", "Height:=", "10mm", "NumSides:=", "20", "WhichAxis:=", "Z"), Array("NAME:Attributes", "Name:=", "Peri" & fascicle_number, "Flags:=", "", "Color:=", "(255 62 62)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Perineurium" & Chr(34) & "", "SolveInside:=", true)
'			oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Peri" & fascicle_number & ":CreateRegularPolyhedron:1"), Array("NAME:ChangedProps", Array("NAME:Center Position", "X:=", "$Peri" & fascicle_number & "X", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"), Array("NAME:Start Position", "X:=", "$Peri" & fascicle_number & "X+$Peri" & fascicle_number & "R", "Y:=", "$Peri" & fascicle_number & "Y", "Z:=", "-25mm"))))
'			oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Peri" & fascicle_number, "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
'		next
'	loop
'	'Epi
'	oProject.ChangeProperty Array("NAME:AllTabs", Array("NAME:ProjectVariableTab", Array("NAME:PropServers", "ProjectVariables"), Array("NAME:ChangedProps", Array("NAME:$encapsulation_thickness", "Value:=", encapsulation_thickness & "mm"))))
'	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "0mm", "YPosition:=", "0mm", "ZPosition:=", "0mm", "XSize:=", "1mm", "YSize:=", "1mm", "ZSize:=", "1mm"), Array("NAME:Attributes", "Name:=", "Epineurium", "Flags:=", "", "Color:=", "(255 234 234)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Epineurium" & Chr(34) & "", "SolveInside:=", true)
'	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Epineurium:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_inner/2 + $encapsulation_thickness", "Y:=", "-$cuff_height_inner/2 + $encapsulation_thickness", "Z:=", "-25mm"), Array("NAME:XSize", "Value:=", "$cuff_length_inner - 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_inner - 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "10mm"))))
'	oEditor.DuplicateAlongLine Array("NAME:Selections", "Selections:=", "Epineurium", "NewPartsModelFlag:=", "Model"), Array("NAME:DuplicateToAlongLineParameters", "CreateNewObjects:=", true, "XComponent:=", "0mm", "YComponent:=", "0mm", "ZComponent:=", "10mm", "NumClones:=", "5"), Array("NAME:Options", "DuplicateAssignments:=", false)
'
'	objFileToRead.Close
'    Set objFileToRead = Nothing
'	
'	'Encapsulation
'	oEditor.CreateBox Array("NAME:BoxParameters", "XPosition:=", "-2.5mm", "YPosition:=", "2mm", "ZPosition:=", "0mm", "XSize:=", "0.5mm", "YSize:=", "-0.5mm", "ZSize:=", "-9.5mm"), Array("NAME:Attributes", "Name:=", "Encapsulation", "Flags:=", "", "Color:=", "(255 255 198)", "Transparency:=", 0.6, "PartCoordinateSystem:=", "Global", "UDMId:=", "", "MaterialValue:=", "" & Chr(34) & "Encapsulation" & Chr(34) & "", "SolveInside:=", true)
'	oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DCmdTab", Array("NAME:PropServers", "Encapsulation:CreateBox:1"), Array("NAME:ChangedProps", Array("NAME:Position", "X:=", "-$cuff_length_outer/2 - $encapsulation_thickness", "Y:=", "-$cuff_height_outer/2 - $encapsulation_thickness", "Z:=", "-$cuff_width/2 - $encapsulation_thickness"), Array("NAME:XSize", "Value:=", "$cuff_length_outer + 2*$encapsulation_thickness"), Array("NAME:YSize", "Value:=", "$cuff_height_outer + 2*$encapsulation_thickness"), Array("NAME:ZSize", "Value:=", "$cuff_width + 2*$encapsulation_thickness"))))
'	oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Encapsulation", "Tool Parts:=", "Epineurium_1,Epineurium_2,Epineurium_3"), Array("NAME:SubtractParameters", "KeepOriginals:=", true)
'
'	'Define which contact are running model of
'	Set oModule = oDesign.GetModule("BoundarySetup")
'	for other_contacts = 1 to 15
'		if other_contacts <> contact_number then
'			oModule.DeleteBoundaries Array("Current" & other_contacts)
'		end if
'	next
'	oProject.Save
'
'	'oModule.EditSetup "Setup1", Array("NAME:Setup1", "Enabled:=", true, "MaximumPasses:=", 3, "MinimumPasses:=", 2, "MinimumConvergedPasses:=", 1, "PercentRefinement:=", 30, "SolveFieldOnly:=", false, "PercentError:=", 1, "SolveMatrixAtLast:=", true, "PercentError:=", 1, "UseIterativeSolver:=", false, "RelativeResidual:=", 1E-006, "ComputePowerLoss:=", false, "ThermalFeedback:=", false)
'	'Analyze Model
'	oDesign.AnalyzeAll
'   'Save and Close
'	oProject.Save
'	oDesktop.CloseProject ModelNameShort & contact_number
'next