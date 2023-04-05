'MEDIAN NERVE (20 FASCICLES) WITH ENCAPSULATION 
'Variables to change'

ModelNameShort = "S107 M19F1 20 NE 16CwAS CFINE C"
ModelName = "D:\ICNerveModels\S107_Median19Frame1Modeling\20 Fascicles\NoEncapsulation\" & ModelNameShort
FascCoordsFileName = "D:\ICNerveModels\S107_Median19Frame1Modeling\20 Fascicles\NoEncapsulation\M19T1_20_NoEncap_fasccoord.txt"
VoutFileName = "D:\ICNerveModels\S107_Median19Frame1Modeling\20 Fascicles\NoEncapsulation\M19T1_20_NoEncap_Vout"
NumFascicles = 20
encapsulation_thickness = 0

Dim oAnsoftApp
Dim oDesktop
Dim oProject
Dim oDesign
Dim oEditor
Dim oModule
Set oAnsoftApp = CreateObject("AnsoftMaxwell.MaxwellScriptInterface")
Set oDesktop = oAnsoftApp.GetAppDesktop()
oDesktop.RestoreWindow

for contact_number = 1 to 15  
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





  'ULNAR NERVE (14 FASCICILES) WITH ENCAPSULATION
   'VARIABLES TO CHANGE
'ModelNameShort = "S107 U20T34 14 NE 16CwAS CFINE C"
'ModelName = "D:\ICNerveModels\S107_Ulnar20Frame34Modeling\14 Fascicles\NoEncapsulation\" & ModelNameShort
'FascCoordsFileName = "D:\ICNerveModels\S107_Ulnar20Frame34Modeling\14 Fascicles\NoEncapsulation\U20T34_14_NoEncap_fasccoord.txt"
'VoutFileName = "D:\ICNerveModels\S107_Ulnar20Frame34Modeling\14 Fascicles\NoEncapsulation\U20T34_14_NoEncap_Vout"
'NumFascicles = 14
'encapsulation_thickness = 0

'for contact_number = 1 to 15  
  'Open project
'  oDesktop.OpenProject ModelName & contact_number & ".mxwl"
'  Set oProject = oDesktop.SetActiveProject(ModelNameShort & contact_number)
'  Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
  'Export Voltages and Close
'  Set oModule = oDesign.GetModule("FieldsReporter")
'  oModule.EnterQty "Voltage"
  
	
'	for fascicle_number = 1 to NumFascicles	
	
'		X = oProject.GetVariableValue("$Endo" & fascicle_number & "X")
'		Y = oProject.GetVariableValue("$Endo" & fascicle_number & "Y")
'		R = oProject.GetVariableValue("$Endo" & fascicle_number & "R")
'		With (New RegExp)
'			.Global = True
'			.Pattern = "[m]"
'			X = .Replace(X,"")
'			Y = .Replace(Y,"")
'			R = .Replace(R,"")
'		End With
'    X = CDbl(X)
'    Y = CDbl(Y)
'    R = CDbl(R)

'		oModule.ExportOnGrid VoutFileName & "Cathode" & contact_number & "Fascicle" & fascicle_number & ".fld", _
'       Array((X-R) & "mm", (Y-R) & "mm", "-25mm"), _
'       Array((X+R) & "mm", (Y+R) & "mm", "25mm"), _
'       Array((R/20.001) & "mm", (R/20.001) & "mm", "0.25mm"), _
'       "Setup1 : LastAdaptive", _
'       Array(), _
'       true   
'	next
  
 'Save and Close
'	oProject.Save
'	oDesktop.CloseProject ModelNameShort & contact_number
'next
