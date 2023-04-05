'MEDIAN NERVE (13 Fascicles) WITH OR WITHOUT ENCAPSULATION
'JUST ADD/REMOVE "NO" AND CHANGE ENCAP THICKNESS
'Variables to change'
ModelNameShort = "S109 M7F39 NE 16CwAS CFINE C"
ModelName = "E:\ICNerveModels\S109_Median7Frame39_LargerCuff\" & ModelNameShort
FascCoordsFileName = "E:\ICNerveModels\S109_Median7Frame39_LargerCuff\M7T39_NoEncap_fasccoords.txt"
VoutFileName = "E:\ICNerveModels\S109_Median7Frame39_LargerCuff\M7T39_NoEncap_Vout"
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

for contact_number = 5 to 5  
  'Open project
  oDesktop.OpenProject ModelName & contact_number & ".mxwl"
  Set oProject = oDesktop.SetActiveProject(ModelNameShort & contact_number)
  Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
  'Export Voltages and Close
  Set oModule = oDesign.GetModule("FieldsReporter")
  oModule.EnterQty "Voltage"
  
	
	for fascicle_number = 1 to NumFascicles	
	
		X = oProject.GetVariableValue("$Endo" & fascicle_number & "X")
		Y = oProject.GetVariableValue("$Endo" & fascicle_number & "Y")
		R = oProject.GetVariableValue("$Endo" & fascicle_number & "R")
		With (New RegExp)
			.Global = True
			.Pattern = "[m]"
			X = .Replace(X,"")
			Y = .Replace(Y,"")
			R = .Replace(R,"")
		End With
    X = CDbl(X)
    Y = CDbl(Y)
    R = CDbl(R)

	oModule.ExportOnGrid VoutFileName & "Cathode" & contact_number & "Fascicle" & fascicle_number & ".fld", _
       Array((X-R) & "mm", (Y-R) & "mm", "-25mm"), _
       Array((X+R) & "mm", (Y+R) & "mm", "25mm"), _
       Array((R/20.001) & "mm", (R/20.001) & "mm", "0.25mm"), _
       "Setup1 : LastAdaptive", _
       Array(), _
       true   
	next
  
 'Save and Close
	oProject.Save
	oDesktop.CloseProject ModelNameShort & contact_number
next
