Option Explicit

Const CAT_ISO = 1
Const CAT_PAPER_A3 = 5
Const CAT_PAPER_LANDSCAPE = 1
Const CAT_FIRST_ANGLE = 0

Const CAT_RIGHT_VIEW = 0
Const CAT_LEFT_VIEW = 1
Const CAT_TOP_VIEW = 2
Const CAT_BOTTOM_VIEW = 3
Const CAT_REAR_VIEW = 4

Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")

Dim outputDir
outputDir = fso.GetAbsolutePathName("output")
If Not fso.FolderExists(outputDir) Then
  fso.CreateFolder outputDir
End If

Dim CATIA
On Error Resume Next
Set CATIA = GetObject(, "CATIA.Application")
If Err.Number <> 0 Or CATIA Is Nothing Then
  WScript.Echo "ERROR: Cannot connect to a running CATIA session."
  WScript.Quit 1
End If
On Error GoTo 0

CATIA.DisplayFileAlerts = False

Dim preferredProductName
preferredProductName = "$PRODUCT_NAME$"

Dim sourceDoc
Set sourceDoc = ResolveProductDocument(preferredProductName)
If sourceDoc Is Nothing Then
  WScript.Echo "ERROR: Cannot find or open " & preferredProductName
  WScript.Quit 1
End If

Dim sourceProduct
Set sourceProduct = sourceDoc.Product

Dim baseName
baseName = fso.GetBaseName(sourceDoc.Name)

Dim existingDocIndex
For existingDocIndex = CATIA.Documents.Count To 1 Step -1
  If TypeName(CATIA.Documents.Item(existingDocIndex)) = "DrawingDocument" _
     And (LCase(CATIA.Documents.Item(existingDocIndex).Name) = LCase(baseName & "_multiview.CATDrawing") _
       Or LCase(CATIA.Documents.Item(existingDocIndex).Name) = LCase(baseName & "_views.CATDrawing")) Then
    CATIA.Documents.Item(existingDocIndex).Close
  End If
Next

Dim drawingDoc
Set drawingDoc = CATIA.Documents.Add("Drawing")
drawingDoc.Standard = CAT_ISO

Dim sheet
Set sheet = drawingDoc.Sheets.Item(1)
sheet.PaperSize = CAT_PAPER_A3
sheet.Orientation = CAT_PAPER_LANDSCAPE
sheet.ProjectionMethod = CAT_FIRST_ANGLE
sheet.Scale = 0.2

Dim views
Set views = sheet.Views

Dim frontView
Set frontView = AddFrontView(views, sourceProduct, "Front view", 170, 150, 0.2)

AddOrthographicView views, sourceProduct, "Right view", 270, 150, 0.2, 0, 1, 0, 0, 0, 1
AddOrthographicView views, sourceProduct, "Left view", 70, 150, 0.2, 0, -1, 0, 0, 0, 1
AddOrthographicView views, sourceProduct, "Top view", 170, 230, 0.2, 1, 0, 0, 0, 1, 0
AddOrthographicView views, sourceProduct, "Bottom view", 170, 70, 0.2, 1, 0, 0, 0, -1, 0
AddOrthographicView views, sourceProduct, "Rear view", 370, 150, 0.2, -1, 0, 0, 0, 0, 1
AddIsometricView views, sourceProduct, "Isometric view", 350, 235, 0.2

sheet.ForceUpdate
drawingDoc.Update

Dim drawingPath
drawingPath = fso.BuildPath(outputDir, baseName & "_multiview.CATDrawing")
If fso.FileExists(drawingPath) Then fso.DeleteFile drawingPath, True
drawingDoc.SaveAs drawingPath

Dim pdfPath
pdfPath = fso.BuildPath(outputDir, baseName & "_multiview.pdf")
If fso.FileExists(pdfPath) Then fso.DeleteFile pdfPath, True
On Error Resume Next
drawingDoc.ExportData pdfPath, "pdf"
If Err.Number <> 0 Then
  WScript.Echo "WARN: CATDrawing saved, but PDF export failed: " & Err.Description
  Err.Clear
End If
On Error GoTo 0

WScript.Echo "OK: " & drawingPath
If fso.FileExists(pdfPath) Then
  WScript.Echo "OK: " & pdfPath
End If

Function AddFrontView(ByVal drawingViews, ByVal product, ByVal name, ByVal x, ByVal y, ByVal scale)
  Dim view
  Set view = drawingViews.Add(name)
  view.x = x
  view.y = y
  view.Scale = scale
  view.GenerativeBehavior.Document = product
  view.GenerativeBehavior.DefineFrontView 1, 0, 0, 0, 0, 1
  view.GenerativeBehavior.Update
  Set AddFrontView = view
End Function

Function ResolveProductDocument(ByVal productSpec)
  Set ResolveProductDocument = FindDocumentByName(productSpec, "ProductDocument")
  If Not ResolveProductDocument Is Nothing Then Exit Function

  If fso.FileExists(productSpec) Then
    Set ResolveProductDocument = CATIA.Documents.Open(productSpec)
    Exit Function
  End If

  Dim baseNameOnly
  baseNameOnly = fso.GetFileName(productSpec)
  If Len(baseNameOnly) > 0 Then
    Set ResolveProductDocument = FindDocumentByName(baseNameOnly, "ProductDocument")
  End If
End Function

Function FindDocumentByName(ByVal docName, ByVal expectedType)
  Dim i, doc, baseNameOnly
  Set FindDocumentByName = Nothing
  baseNameOnly = fso.GetFileName(docName)
  For i = 1 To CATIA.Documents.Count
    Set doc = CATIA.Documents.Item(i)
    If TypeName(doc) = expectedType Then
      If LCase(doc.Name) = LCase(docName) Or LCase(doc.Name) = LCase(baseNameOnly) Then
        Set FindDocumentByName = doc
        Exit Function
      End If
    End If
  Next
End Function

Function AddOrthographicView(ByVal drawingViews, ByVal product, ByVal name, ByVal x, ByVal y, ByVal scale, ByVal x1, ByVal y1, ByVal z1, ByVal x2, ByVal y2, ByVal z2)
  Dim view
  Set view = drawingViews.Add(name)
  view.x = x
  view.y = y
  view.Scale = scale
  view.GenerativeBehavior.Document = product
  view.GenerativeBehavior.DefineFrontView x1, y1, z1, x2, y2, z2
  view.GenerativeBehavior.Update
  Set AddOrthographicView = view
End Function

Function AddIsometricView(ByVal drawingViews, ByVal product, ByVal name, ByVal x, ByVal y, ByVal scale)
  Dim view
  Set view = drawingViews.Add(name)
  view.x = x
  view.y = y
  view.Scale = scale
  view.GenerativeBehavior.Document = product
  view.GenerativeBehavior.DefineIsometricView 1, 1, 1, 0, 0, 1
  view.GenerativeBehavior.Update
  Set AddIsometricView = view
End Function
