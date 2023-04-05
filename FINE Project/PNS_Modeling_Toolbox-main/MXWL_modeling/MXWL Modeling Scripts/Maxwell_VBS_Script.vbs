
'Modified PVL 2/3/16. combining build, run, export voltage.
' Further modified 2/10/16. Opening an old maxwell file first so voltage export works
' Furtherer modified 6/6/16. Now identifies own location and reads params from text file(thanks Josh).
' ... This VBS script is called by ProcessSM2.m

' 2/3/16
' so this is almost entirely Matt's build 270L models.vbs script
' I've made a few changes - no more mirroring, which should slow things down, but makes things easier for me to generate
' also, the maxwell 14 version I'm using doesn't like calculating voltages, 
' but opening a gutted copy of his mxwl file ("Frankenstein.mxwl") still allows that.

'6/6/16 - with help from Josh
' Now identifies own location and reads from param file
' spacing on top and bottom modified to fit schematics and generate correct structure
' anode added

' 6/13/16
' anode well/window size reduced (1mm less on width, 0.5mm on each side), Z dimension now anodeZ - 0.2 and offset by 0.1 on either side
' all contacts are now modeled, even if only one is used.


' ----------------------------------------------
' Script Recorded by Ansoft Maxwell Version 12.0
' 3:42 PM  Nov 02, 2009
' ----------------------------------------------


'******Things to adjust before starting:
'  MyDirectory. The directory in which this file is located
'  SM2Filename.
'  NumberOfFascicles
'  Encapsulation?
'  X and Y dimensions of cuff


Dim fSystem
set fSystem = CreateObject("Scripting.FileSystemObject")

Set objShell = CreateObject("Wscript.Shell")
strPath = objShell.CurrentDirectory
MyDirectory= strPath
ReadFileName = MyDirectory & "/VBSparams.txt"

Set ReadFile = fSystem.OpenTextFile(ReadFileName, 1)

'txt file with paramters should have the cdbl(values listed in same order as they are set in this file
'for setting parameters, replace number cdbl(values with ReadFile.ReadLine()
'ReadFile.Close



'Declare Ansoft Variables'
Dim oAnsoftApp
Dim oDesktop
Dim oProject
Dim oDesign
Dim oEditor
Dim oModule

'Set Ansoft Variables'
Set oAnsoftApp = CreateObject("AnsoftMaxwell.MaxwellScriptInterface")
Set oDesktop = oAnsoftApp.GetAppDesktop()

'Create Model-Specific Variables for VBS'
Dim ModelName

'Contact Variables (fixed)'
Dim ContactX              'mm; size'
Dim ContactY              'mm; size'
Dim ContactZ              'mm; size'
Dim ContactDepth          'mm; size'
Dim ContactCenterX        'mm; location'
Dim ContactCenterY        'mm; location'
Dim ContactCenterZ        'mm; location'
Dim NumberOfContacts

'Anode Strip Variables
Dim AnodeX				  'mm; size'
Dim AnodeY				  'mm; size'
Dim AnodeZ				  'mm; size'
Dim AnodeDepth			  'mm; size'

'Cuff Variables (variable and fixed)'
Dim CuffX                 'mm; cuff width: 15.25, 12.25, 10.25mm'
Dim CuffY                 'mm; cuff height: 3.00, 2.75, 2.50, 2.25, 2mm'
Dim CuffZ                 'mm; cuff length along nerve: 10mm'
Dim CuffWallThickness     'mm'
Dim WellRadius            'mm'
Dim WellHeight
Dim WellCenterX
Dim WellCenterY
Dim WellCenterZ

'Saline Variables (fixed)'
Dim SalineX                'mm; size'
Dim SalineY                'mm; size'
Dim SalineZ                'mm; size'

'Nerve Variables (variable and fixed)'
Dim NerveZ                 'mm; size'
Dim EncapsulationThickness 'mm; size'
Dim NumberOfFascicles

'Loop Indices'
Dim IndexCuffX
Dim IndexCuffY
Dim IndexEncapsulationThickness
Dim IndexFascicleNumber
Dim IndexContactNumber
Dim IndexMirrorVersion

'Folder/Path Variables'
Dim EncapsulationFolderString

'MATLAB Reshaping Variables'
Dim BufferThickness

'Set fixed cdbl(values'

ModelName="Simple" 

SM2FileName = ReadFile.ReadLine()

NumberOfFascicles=cint(ReadFile.ReadLine())
CuffX=cdbl(ReadFile.ReadLine())
CuffY=cdbl(ReadFile.ReadLine())
CuffZ=cdbl(ReadFile.ReadLine())


TopBufferThickness=cdbl(ReadFile.ReadLine()) 'space between contacts along top
BtmBufferThickness=cdbl(ReadFile.ReadLine()) 'space between contacts along bottom

NumberOfContactsTop=cint(ReadFile.ReadLine())
NumberOfContactsBtm=cint(ReadFile.ReadLine())

EncapsulationThickness=cdbl(ReadFile.ReadLine())
IndexEncapsulationThickness = cint(ReadFile.ReadLine()) '   "2" triggers encapsulation

UseDistantAnode=cint(ReadFile.ReadLine())
AnodeZ=cdbl(ReadFile.ReadLine())

ContactX=cdbl(ReadFile.ReadLine())'contact dimensions
ContactY=cdbl(ReadFile.ReadLine())
ContactZ=cdbl(ReadFile.ReadLine())
ContactDepth=cdbl(ReadFile.ReadLine())

NerveZ=cdbl(ReadFile.ReadLine())
CuffWallThickness=cdbl(ReadFile.ReadLine())
WellDiameter=cdbl(ReadFile.ReadLine())
WellHeight=cdbl(ReadFile.ReadLine())
SalineX=cdbl(ReadFile.ReadLine())
SalineY=cdbl(ReadFile.ReadLine())
SalineZ=cdbl(ReadFile.ReadLine())



ReadFile.Close

'Dummy Variables'
Dim TempFace 
Dim TempFace1
'Dim TempFace2
'Dim TempFace3
'Dim TempFace4
'Dim TempFace5
Dim DummyCounter
Dim StartCounter


DummyCounter=1
StartCounter=0  '0 to start at the beginning, otherwise, the number of files that were previously created and don't need to be re-created'

EncapsulationFolderString="No "
'Start Loops'


      for IndexContactNumber = 1 to NumberOfContactsTop+NumberOfContactsBtm
            
            'Is DummyCouter ok?'
            if DummyCounter>StartCounter then
          
          '    'Open the new project'
          '    oDesktop.RestoreWindow
          '    
          '    Set oProject = oDesktop.NewProject
          '    oProject.InsertDesign "Maxwell 3D", "Maxwell3DDesign1", "DCConduction", ""
              
                'Open the existing mxwl file' 
		oDesktop.OpenProject (MyDirectory & "/Frankenstein.mxwl")	
		Set oProject = oDesktop.SetActiveProject("Frankenstein")

              Set oDesign = oProject.SetActiveDesign("Maxwell3DDesign1")
              Set oEditor = oDesign.SetActiveEditor("3D Modeler")
              
              oDesign.SetDesignSettings Array("NAME:Design Settings Data", "Allow Material Override:=", false, "PerfectConductorThreshold:=", 1E+015, "InsulatorThreshold:=", 1E-015, "AmbientTemperature:=", "1cel")
              
              
              'Create Silicone Cuff'
              'Create inner edge of cuff'
              oEditor.CreateBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
              "XPosition:=", -CuffX/2-CuffWallThickness & "mm", "YPosition:=", -CuffY/2-CuffWallThickness & "mm", "ZPosition:=",-CuffZ/2 & "mm", _
              "XSize:=", CuffX+2*CuffWallThickness & "mm", "YSize:=", CuffY+2*CuffWallThickness & "mm", "ZSize:=", CuffZ & "mm"), _
              Array("NAME:Attributes", "Name:=", "Box1", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0.5, "PartCoordinateSystem:=", "Global", "MaterialName:=", "silicon", "SolveInside:=", false)
              


              'Create inner edge of cuff'
              oEditor.CreateBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
              "XPosition:=", -CuffX/2 & "mm", "YPosition:=", -CuffY/2 & "mm", "ZPosition:=",-CuffZ/2 & "mm", _
              "XSize:=", CuffX & "mm", "YSize:=", CuffY & "mm", "ZSize:=", CuffZ & "mm"), _
              Array("NAME:Attributes", "Name:=", "Box2", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0.5, "PartCoordinateSystem:=", "Global", "MaterialName:=", "silicon", "SolveInside:=", false)
              


              'Subtract inner from outer to create frame'
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Box1", "Tool Parts:=", "Box2"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", false)
              


              'Rename'
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Box1"), Array("NAME:ChangedProps", Array("NAME:Name", "Value:=", "Cuff"))))

              'Create Platinum Contact'

              'Determine X-location, Y-location'
              if (IndexContactNumber <= NumberOfContactsTop) then 		'if on top row

			if (NumberOfContactsTop Mod 2) = 1 then			' if odd number of contacts on top row -> contact in center 
				ContactCenterX = ((cdbl(NumberOfContactsTop)/2.0+0.5)-cdbl(IndexContactNumber))*(contactX+TopBufferThickness) 'int division funky

			else							' even number of contacts on top row -> spacing in center 
				ContactCenterX = ( (cdbl(NumberOfContactsTop)/2.0)-cdbl(IndexContactNumber)+0.5)*(contactX+BtmBufferThickness)
			end if
				
		ContactCenterY=CuffY/2+ContactDepth
                ContactCenterZ=0
                ContactHeight=ContactY
                WellCenterX=ContactCenterX
                WellCenterY=CuffY/2
                WellCenterZ=ContactCenterZ
                WellDepth=WellHeight
              else 								'if on btm Row

		if (NumberOfContactsBtm Mod 2) = 1 then				' if odd number of contacts on btm row -> contact in center 
			ContactCenterX = (cdbl(IndexContactNumber-NumberOfContactsTop)-(cdbl(NumberOfContactsBtm)/2.0+0.5))*(contactX+BtmBufferThickness) 'int division funky
		else								' even number of contacts on btm row -> spacing in center 
			ContactCenterX = (cdbl(IndexContactNumber-NumberOfContactsTop)-(cdbl(NumberOfContactsBtm)/2.0)-0.5)*(contactX+BtmBufferThickness)
		end if				

                ContactCenterY=-CuffY/2-ContactDepth
                ContactCenterZ=0
                ContactHeight=-ContactY
                WellCenterX=ContactCenterX
                WellCenterY=-CuffY/2
                WellCenterZ=ContactCenterZ
                WellDepth=-WellHeight
              end if

              'Determine Y-location; may be mirrored later'
              'ContactCenterY=-CuffY/2-ContactDepth
              
              'May need to mirror about the xz-plane'
              if IndexMirrorVersion=2 then
                ContactCenterY=ContactCenterY*-1
                ContactHeight=ContactHeight*-1
                WellCenterY=WellCenterY*-1
                WellDepth=WellDepth*-1
              end if
			  
			  'Add Anode Strips'
			  
			  'Create object to act as AnodeProximal'
			  oEditor.createBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
			  "XPosition:=", -CuffX/2 & "mm", "YPosition:=", CuffY/2+ContactDepth & " mm", "ZPosition:=", -CuffZ/2+1 & "mm", _
			  "XSize:=", CuffX& "mm", "YSize:=", ContactY& "mm", "Zsize:=", AnodeZ & "mm"), _
			  Array("NAME:Attributes", "Name:=", "AnodeProximal", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "platinum", "SolveInside:=", true)
			  
			  'Create object to act as AnodeDistal'
			  oEditor.createBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
			  "XPosition:=", -CuffX/2 & "mm", "YPosition:=", CuffY/2+ContactDepth & " mm", "ZPosition:=", CuffZ/2-1-AnodeZ & "mm", _
			  "XSize:=", CuffX & "mm", "YSize:=", ContactY & "mm", "Zsize:=", AnodeZ & "mm"), _
			  Array("NAME:Attributes", "Name:=", "AnodeDistal", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "platinum", "SolveInside:=", true)
              
			  'Create Well for Strip - Proximal
			  oEditor.createBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
			  "XPosition:=", -CuffX/2+0.5 & "mm", "YPosition:=", CuffY/2 & " mm", "ZPosition:=", -CuffZ/2+1.1  & "mm", _
			  "XSize:=", CuffX-1 & "mm", "YSize:=", WellHeight & "mm", "Zsize:=", AnodeZ -0.2 & "mm"), _
			  Array("NAME:Attributes", "Name:=", "WellProximal", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)
              
			  'Create Well for Strip - Distal
			  oEditor.createBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
			  "XPosition:=", -CuffX/2+0.5 & "mm", "YPosition:=", CuffY/2 & " mm", "ZPosition:=", CuffZ/2-1-AnodeZ+0.1 & "mm", _
			  "XSize:=", CuffX-1 & "mm", "YSize:=", WellHeight & "mm", "Zsize:=", AnodeZ -0.2 & "mm"), _
			  Array("NAME:Attributes", "Name:=", "WellDistal", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)
              



              'Create object to act as contact'
              oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "CoordinateSystemID:=", -1, _ 
              "XCenter:=", ContactCenterX & "mm", "YCenter:=", ContactCenterY & "mm", "ZCenter:=", ContactCenterZ & "mm", _
              "XStart:=",  ContactCenterX+ContactX/2 & "mm", "YStart:=", ContactCenterY & "mm", "ZStart:=", ContactCenterZ & "mm", _ 
              "Height:=", ContactHeight & "mm", _
              "NumSides:=", "20", "WhichAxis:=", "Y"), _ 
              Array("NAME:Attributes", "Name:=", "Contact1", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "platinum", "SolveInside:=", true)
              
              'Create Well for Contact'
              oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "CoordinateSystemID:=", -1, _ 
              "XCenter:=", WellCenterX & "mm", "YCenter:=", WellCenterY & "mm", "ZCenter:=", WellCenterZ & "mm", _
              "XStart:=",  WellCenterX+WellDiameter/2 & "mm", "YStart:=", WellCenterY & "mm", "ZStart:=", ContactCenterZ & "mm", _ 
              "Height:=", WellDepth & "mm", _
              "NumSides:=", "20", "WhichAxis:=", "Y"), _ 
              Array("NAME:Attributes", "Name:=", "Well", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)
              
              'Set Stim on Contact'
              TempFace = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
              "BodyName:=", "Contact1",_
              "XPosition:=", ContactCenterX & "mm",_
              "YPosition:=", ContactCenterY & "mm",_
              "ZPosition:=", ContactCenterZ & "mm"))
              
              
              Set oModule = oDesign.GetModule("BoundarySetup")
              oModule.AssignCurrent Array("NAME:Current1", "Faces:=", Array(TempFace), "Current:=", "-1mA", "Point out of terminal:=", true)
      



		' Create all other contacts to act as metal
		for tempIndexContactNumber = 1 to NumberOfContactsTop+NumberOfContactsBtm	

			'Determine X-location, Y-location'
	              if (tempIndexContactNumber <= NumberOfContactsTop) then 		'if on top row

			if (NumberOfContactsTop Mod 2) = 1 then			' if odd number of contacts on top row -> contact in center 
				ContactCenterX = ((cdbl(NumberOfContactsTop)/2.0+0.5)-cdbl(tempIndexContactNumber))*(contactX+TopBufferThickness) 'int division funky

			else							' even number of contacts on top row -> spacing in center 
				ContactCenterX = ( (cdbl(NumberOfContactsTop)/2.0)-cdbl(tempIndexContactNumber)+0.5)*(contactX+BtmBufferThickness)
			end if
				
			ContactCenterY=CuffY/2+ContactDepth
	                ContactCenterZ=0
	                ContactHeight=ContactY
	                WellCenterX=ContactCenterX
	                WellCenterY=CuffY/2
	                WellCenterZ=ContactCenterZ
	                WellDepth=WellHeight
	              else 								'if on btm Row
	
			if (NumberOfContactsBtm Mod 2) = 1 then				' if odd number of contacts on btm row -> contact in center 
				ContactCenterX = (cdbl(tempIndexContactNumber-NumberOfContactsTop)-(cdbl(NumberOfContactsBtm)/2.0+0.5))*(contactX+BtmBufferThickness) 'int division funky
			else								' even number of contacts on btm row -> spacing in center 
				ContactCenterX = (cdbl(tempIndexContactNumber-NumberOfContactsTop)-(cdbl(NumberOfContactsBtm)/2.0)-0.5)*(contactX+BtmBufferThickness)
			end if				
	
	                ContactCenterY=-CuffY/2-ContactDepth
	                ContactCenterZ=0
	                ContactHeight=-ContactY
	                WellCenterX=ContactCenterX
	                WellCenterY=-CuffY/2
	                WellCenterZ=ContactCenterZ
	                WellDepth=-WellHeight
	              end if	


			if (tempIndexContactNumber <> IndexContactNumber) then 'not equal to operator
          		    oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "CoordinateSystemID:=", -1, _ 
		              "XCenter:=", ContactCenterX & "mm", "YCenter:=", ContactCenterY & "mm", "ZCenter:=", ContactCenterZ & "mm", _
		              "XStart:=",  ContactCenterX+ContactX/2 & "mm", "YStart:=", ContactCenterY & "mm", "ZStart:=", ContactCenterZ & "mm", _ 
		              "Height:=", ContactHeight & "mm", _
		              "NumSides:=", "20", "WhichAxis:=", "Y"), _ 
		              Array("NAME:Attributes", "Name:=", "NonStimulatingContact"& tempIndexContactNumber, "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "platinum", "SolveInside:=", true)
              
              		'Create Well for Contact'
		              oEditor.CreateRegularPolyhedron Array("NAME:PolyhedronParameters", "CoordinateSystemID:=", -1, _ 
		              "XCenter:=", WellCenterX & "mm", "YCenter:=", WellCenterY & "mm", "ZCenter:=", WellCenterZ & "mm", _
		              "XStart:=",  WellCenterX+WellDiameter/2 & "mm", "YStart:=", WellCenterY & "mm", "ZStart:=", ContactCenterZ & "mm", _ 
		              "Height:=", WellDepth & "mm", _
		              "NumSides:=", "20", "WhichAxis:=", "Y"), _ 
		              Array("NAME:Attributes", "Name:=", "NonStimulatingContactWell"& tempIndexContactNumber, "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)

			end if

		next 'seems to end for statements



              'Import the correct SM2 file describing the fascicles'
              oEditor.Import Array("NAME:NativeBodyParameters", "CoordinateSystemID:=", -1, "HealOption:=", 0, "CheckModel:=", true, "Options:=", "-1", "FileType:=", "UnRecognized", "SourceFile:=", _
              MyDirectory  & "/" & SM2FileName)
              
              'Delete Epineurium that was imported'
              oEditor.Delete Array("NAME:Selections", "Selections:=", "Epineurium")
      
	      'Fascicle-by-fascicle commands'
              for IndexFascicleNumber = 1 to NumberOfFascicles
                'Move 2d object'
                oEditor.Move Array("NAME:Selections", "Selections:=",  "Endo" & IndexFascicleNumber & ", Peri" & IndexFascicleNumber , "NewPartsModelFlag:=", "Model"), _ 
                Array("NAME:TranslateParameters", "CoordinateSystemID:=", -1, "TranslateVectorX:=", "0mm", "TranslateVectorY:=", "0mm", "TranslateVectorZ:=", -NerveZ/2 & "mm")
                
                'Sweep to create 3d object'
                oEditor.SweepAlongVector Array("NAME:Selections", "Selections:=",  "Endo" & IndexFascicleNumber & ", Peri" & IndexFascicleNumber, "NewPartsModelFlag:=", "Model"), _
                Array("NAME:VectorSweepParameters", "CoordinateSystemID:=", -1, "DraftAngle:=", "0deg", "DraftType:=", "Round", "CheckFaceFaceIntersection:=", false, "SweepVectorX:=", "0mm", "SweepVectorY:=", "0mm", "SweepVectorZ:=",  NerveZ & "mm")
                


	'	'PVL Added - cut intersect between Endo and Peri from Endo'
		oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Peri" & IndexFascicleNumber, "Tool Parts:=",  _
 		 "Endo" & IndexFascicleNumber), Array("NAME:SubtractParameters", "KeepOriginals:=", true)

                
                'Create Mesh Operations'
' These get cut in the run anyway.
   '             Set oModule = oDesign.GetModule("MeshSetup")
   '             oModule.AssignLengthOp Array("NAME:Length" & IndexFascicleNumber, "RefineInside:=", false, "Objects:=", Array("Endo" & IndexFascicleNumber, "Peri" & IndexFascicleNumber), "RestrictElem:=", false, "NumMaxElem:=", "1000", "RestrictLength:=", true, "MaxLength:=", "10mm")
   '             oModule.AssignTrueSurfOp Array("NAME:SurfApprox" & IndexFascicleNumber, "Objects:=", Array("Endo" & IndexFascicleNumber, "Peri" & IndexFascicleNumber), "SurfDevChoice:=", 0, "NormalDevChoice:=", 1, "AspectRatioChoice:=", 2, "AspectRatio:=", "5")
              next  'Fascicle-by-fascicle command'
              
              
              'Create Epineurium'
              oEditor.CreateBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
              "XPosition:=", -CuffX/2+EncapsulationThickness & "mm", "YPosition:=", -CuffY/2+EncapsulationThickness & "mm", "ZPosition:=", -NerveZ/2 & "mm", _
              "XSize:=", CuffX-2*EncapsulationThickness & "mm", "YSize:=", CuffY-2*EncapsulationThickness & "mm", "ZSize:=", NerveZ & "mm"), _
              Array("NAME:Attributes", "Name:=", "Epineurium", "Flags:=", "", "Color:=", "(132 132 193)", "Transparency:=", 0.5, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)
              
              
              
              'Create Encapsulation if needed and subtract from it the cuff'
              if IndexEncapsulationThickness = 2 then
                oEditor.CreateBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _ 
                "XPosition:=", -CuffX/2-CuffWallThickness-EncapsulationThickness & "mm", "YPosition:=", -CuffY/2-CuffWallThickness-EncapsulationThickness & "mm", "ZPosition:=", -CuffZ/2-EncapsulationThickness & "mm", _
                "XSize:=", CuffX+2*CuffWallThickness+2*EncapsulationThickness & "mm", "YSize:=", CuffY+2*CuffWallThickness+2*EncapsulationThickness & "mm", "ZSize:=", CuffZ + EncapsulationThickness*2 & "mm"), _
                Array("NAME:Attributes", "Name:=", "Encapsulation", "Flags:=", "", "Color:=", "(255 255 128)", "Transparency:=", 0.9, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)
                
                'Subtract Cuff from Encapsulation'
                oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Encapsulation", "Tool Parts:=", "Cuff"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", true)
                
                'Subtract Epi from Encapsulation'
                oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Encapsulation", "Tool Parts:=", "Epineurium"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", true)
                end if
              
              'Create Saline'
              oEditor.CreateBox Array("NAME:BoxParameters", "CoordinateSystemID:=", -1, _
              "XPosition:=", -SalineX/2 & "mm", "YPosition:=", -SalineY/2 & "mm", "ZPosition:=", -SalineZ/2 & "mm", _
              "XSize:=", SalineX & "mm", "YSize:=", SalineY & "mm", "ZSize:=", SalineZ & "mm"), _
              Array("NAME:Attributes", "Name:=", "Saline", "Flags:=", "", "Color:=", "(0 0 255)", "Transparency:=", 0, "PartCoordinateSystem:=", "Global", "MaterialName:=", "vacuum", "SolveInside:=", false)
              
             ' if UseDistantAnode=1 then 'Distant Anode

              	      oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Saline"), Array("NAME:ChangedProps", Array("NAME:Display Wireframe", "cdbl(value:=", true))))
	              'Add Sink to sides of saline'
	              TempFace1 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "Saline",_
	              "XPosition:=", 0 & "mm",_
	              "YPosition:=", -SalineY/2 & "mm",_
	              "ZPosition:=", SalineZ/4 & "mm"))
	              TempFace2 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "Saline",_
	              "XPosition:=", 0 & "mm",_
	              "YPosition:=", SalineY/2 & "mm",_
	              "ZPosition:=", SalineZ/4 & "mm"))
	              TempFace3 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "Saline",_
	              "XPosition:=", -SalineX/2 & "mm",_
	              "YPosition:=", 0 & "mm",_
	              "ZPosition:=", SalineZ/4 & "mm"))
	              TempFace4 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "Saline",_
	              "XPosition:=", SalineX/2 & "mm",_
	              "YPosition:=", 0 & "mm",_
	              "ZPosition:=", SalineZ/4 & "mm"))
	              TempFace5 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "Saline",_
	              "XPosition:=", 0 & "mm",_
	              "YPosition:=", 0 & "mm",_
	              "ZPosition:=", SalineZ/2 & "mm"))
	              TempFace6 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "Saline",_
	              "XPosition:=", 0 & "mm",_
	              "YPosition:=", 0 & "mm",_
	              "ZPosition:=", -SalineZ/2 & "mm"))
			  
		      Set oModule = oDesign.GetModule("BoundarySetup")
	              oModule.AssignSink Array("NAME:Sink1", "Faces:=", Array(TempFace1,TempFace2,TempFace3,TempFace4,TempFace5,TempFace6))
              
	 '     else
		      oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "AnodeProximal"), Array("NAME:ChangedProps", Array("NAME:Display Wireframe", "cdbl(value:=", true))))

		      TempFace1 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
		      "BodyName:=", "AnodeProximal",_
	              "XPosition:=", 0 & "mm",_
	              "YPosition:=", CuffY/2+ContactDepth & "mm",_
	              "ZPosition:=", -CuffZ/2+1+AnodeZ/2 & "mm"))

	              TempFace2 = oEditor.GetFaceByPosition(Array("Name:FaceParameters",_
	              "BodyName:=", "AnodeDistal",_
	              "XPosition:=", 0 & "mm",_
	              "YPosition:=", CuffY/2+ContactDepth  & "mm",_
	              "ZPosition:=", CuffZ/2-1-AnodeZ+AnodeZ/2 & "mm"))

	              Set oModule = oDesign.GetModule("BoundarySetup")
	              oModule.AssignSink Array("NAME:Sink2", "Faces:=", Array(TempFace1,TempFace2))
	 '     end if


              'Subtract Contact and Well from cuff'
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "Well"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", false)
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "Contact1"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", true)
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "AnodeDistal"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", true)
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "AnodeProximal"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", true)
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "WellDistal"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", false)
              oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "WellProximal"), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", false)

		' and further subtract off extra contacts
		for tempIndexContactNumber = 1 to NumberOfContactsTop+NumberOfContactsBtm
			if (tempIndexContactNumber <> IndexContactNumber) then	' "<>" means "not"
				oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "NonStimulatingContact"& tempIndexContactNumber), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", true)
				oEditor.Subtract Array("NAME:Selections", "Blank Parts:=", "Cuff", "Tool Parts:=", "NonStimulatingContactWell"& tempIndexContactNumber), Array("NAME:SubtractParameters", "CoordinateSystemID:=", -1, "KeepOriginals:=", false)
			end if
		next
              
              'Create Material Properties'
              Set oDefinitionManager = oProject.GetDefinitionManager()
              oDefinitionManager.AddMaterial Array("NAME:Endoneurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), Array("NAME:conductivity", "property_type:=", "AnisoProperty", "unit:=", "", "component1:=", "0.083", "component2:=", "0.083", "component3:=", "0.571"))
              oDefinitionManager.AddMaterial Array("NAME:Perineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.002")
              oDefinitionManager.AddMaterial Array("NAME:Epineurium", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.083")
              oDefinitionManager.AddMaterial Array("NAME:Encapsulation", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "conductivity:=", "0.1")
              oDefinitionManager.AddMaterial Array("NAME:Saline", "CoordinateSystemType:=", "Cartesian", Array("NAME:AttachedData"), Array("NAME:ModifierData"), "permittivity:=", "81", "permeability:=", "0.999991", "conductivity:=", "2", "thermal_conductivity:=", "0.61")
              
              'Assign Material Properties'
              Set oEditor = oDesign.SetActiveEditor("3D Modeler")
              for IndexFascicleNumber = 1 to NumberOfFascicles
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Endo" & IndexFascicleNumber), Array("NAME:ChangedProps", Array("NAME:Material", "Material:=", "Endoneurium"))))
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Peri" & IndexFascicleNumber), Array("NAME:ChangedProps", Array("NAME:Material", "Material:=", "Perineurium"))))
              next
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Epineurium"), Array("NAME:ChangedProps", Array("NAME:Material", "Material:=", "Epineurium"))))
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Saline"), Array("NAME:ChangedProps", Array("NAME:Material", "Material:=", "Saline"))))
              
              if IndexEncapsulationThickness = 2 then
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Encapsulation"), Array("NAME:ChangedProps", Array("NAME:Material", "Material:=", "Encapsulation"))))
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Encapsulation"), Array("NAME:ChangedProps", Array("NAME:Transparent", "cdbl(value:=", 0.6))))
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Encapsulation"), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 255, "G:=", 255, "B:=", 0))))
              end if
              
              
              'Adjust Appearances'
              for IndexFascicleNumber = 1 to NumberOfFascicles
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Endo" & IndexFascicleNumber), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 224, "G:=", 224, "B:=", 224))))
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Peri" & IndexFascicleNumber), Array("NAME:ChangedProps", Array("NAME:Transparent", "cdbl(value:=", 0.4))))
                oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Peri" & IndexFascicleNumber), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 0, "G:=", 0, "B:=", 0))))
              next
              
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Epineurium"), Array("NAME:ChangedProps", Array("NAME:Transparent", "cdbl(value:=", 0.5))))
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Epineurium"), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 255, "G:=", 0, "B:=", 0))))
              
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Contact1"), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 77, "G:=", 77, "B:=", 77))))
              
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Saline"), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 0, "G:=", 0, "B:=", 255))))
              
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Cuff"), Array("NAME:ChangedProps", Array("NAME:Transparent", "cdbl(value:=", 0.8))))
              oEditor.ChangeProperty Array("NAME:AllTabs", Array("NAME:Geometry3DAttributeTab", Array("NAME:PropServers", "Cuff"), Array("NAME:ChangedProps", Array("NAME:Color", "R:=", 187, "G:=", 255, "B:=", 255))))
              
              'Add Analysis'
              Set oModule = oDesign.GetModule("AnalysisSetup")
              oModule.InsertSetup "DCConduction", Array("NAME:Setup1", "MaximumPasses:=", 100, "MinimumPasses:=", 2, "MinimumConvergedPasses:=", 1, "PercentRefinement:=", 10, "SolveFieldOnly:=", false, "PercentError:=", 1, "SolveMatrixAtLast:=", true, "UseOutputVariable:=", false, "PreAdaptMesh:=", false)

              'Adjust the Analysis to solve to 0.5% error'
              Set oModule = oDesign.GetModule("AnalysisSetup")
              oModule.EditSetup "Setup1", Array("NAME:Setup1", "MaximumPasses:=", 100, "MinimumPasses:=",  _
              2, "MinimumConvergedPasses:=", 1, "PercentRefinement:=", 10, "SolveFieldOnly:=",  _
               false, "PercentError:=", 0.5, "SolveMatrixAtLast:=", true, "UseOutputVariable:=",  _
               false, "PreAdaptMesh:=", false)
              
              'Save and Close project'
              oProject.SaveAs (MyDirectory &"\Maxwell_Output\" & ModelName & IndexContactNumber & ".mxwl"), true

                'Solve'
                oDesign.AnalyzeAll
                'Save'
                oProject.Save

		Set oModule = oDesign.GetModule("FieldsReporter")
                oModule.EnterQty "Voltage"

		for IndexFascicleNumber = 1 to NumberOfFascicles
                    oModule.ExportToFile  _
                    MyDirectory & "\Maxwell_Output\" & ModelName & "Contact" & IndexContactNumber & "FascicleNumber" & IndexFascicleNumber & ".dat",  _
		    MyDirectory & "\ExportLocations\ExportLocationsForEndo" & IndexFascicleNumber  & ".pts", _
                    "Setup1 : LastAdaptive", Array()   
		next 
                      

              oDesktop.CloseProject ModelName & IndexContactNumber
            end if 'End DummyCounter>StartCounter test'
            
            DummyCounter=DummyCounter+1
              
          next 'IndexContactNumber cdbl(value'