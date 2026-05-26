Option Explicit

Const CAT_ISO = 1
Const CAT_PAPER_A3 = 5
Const CAT_PAPER_LANDSCAPE = 1
Const CAT_FIRST_ANGLE = 0

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
CloseScratchDrawings

Dim sourceDoc
Set sourceDoc = ResolveProductDocument("$PRODUCT_NAME$")
If sourceDoc Is Nothing Then
  WScript.Echo "ERROR: Cannot find or open $PRODUCT_NAME$"
  WScript.Quit 1
End If

Dim sourcePath
sourcePath = sourceDoc.FullName
If Len(sourcePath) = 0 Then
  WScript.Echo "ERROR: MiniDrone.CATProduct must be saved before creating an exploded copy."
  WScript.Quit 1
End If

Dim outputBaseName
outputBaseName = "$EXPLODED_BASE_NAME$"

Dim explosionScale
explosionScale = CDbl("$EXPLOSION_SCALE$")

CloseDocumentIfOpen outputBaseName & ".CATDrawing", "DrawingDocument"
CloseDocumentIfOpen outputBaseName & ".CATProduct", "ProductDocument"

Dim explodedProductPath
explodedProductPath = fso.BuildPath(outputDir, outputBaseName & ".CATProduct")
If fso.FileExists(explodedProductPath) Then
  fso.DeleteFile explodedProductPath, True
End If

sourceDoc.Activate
sourceDoc.SaveAs explodedProductPath

Dim explodedDoc
Set explodedDoc = CATIA.ActiveDocument

ExplodeTopLevelProducts explodedDoc.Product
explodedDoc.Save

Dim drawingDoc
Set drawingDoc = CreateExplodedMultiViewDrawing(explodedDoc.Product)

Dim drawingPath
drawingPath = fso.BuildPath(outputDir, outputBaseName & ".CATDrawing")
If fso.FileExists(drawingPath) Then
  fso.DeleteFile drawingPath, True
End If
drawingDoc.SaveAs drawingPath

Dim pdfPath
pdfPath = fso.BuildPath(outputDir, outputBaseName & ".pdf")
If fso.FileExists(pdfPath) Then
  fso.DeleteFile pdfPath, True
End If

On Error Resume Next
drawingDoc.ExportData pdfPath, "pdf"
If Err.Number <> 0 Then
  WScript.Echo "WARN: CATDrawing saved, but PDF export failed: " & Err.Description
  Err.Clear
End If
On Error GoTo 0

If FindDocumentByName(fso.GetFileName(sourcePath), "ProductDocument") Is Nothing Then
  CATIA.Documents.Open sourcePath
End If

WScript.Echo "OK: " & explodedProductPath
WScript.Echo "OK: " & drawingPath
If fso.FileExists(pdfPath) Then
  WScript.Echo "OK: " & pdfPath
End If

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

Sub CloseDocumentIfOpen(ByVal docName, ByVal expectedType)
  Dim i, doc
  For i = CATIA.Documents.Count To 1 Step -1
    Set doc = CATIA.Documents.Item(i)
    If TypeName(doc) = expectedType And LCase(doc.Name) = LCase(docName) Then
      doc.Close
    End If
  Next
End Sub

Sub CloseScratchDrawings()
  Dim i, doc
  For i = CATIA.Documents.Count To 1 Step -1
    Set doc = CATIA.Documents.Item(i)
    If TypeName(doc) = "DrawingDocument" And Left(doc.Name, 7) = "Drawing" Then
      On Error Resume Next
      doc.Close
      Err.Clear
      On Error GoTo 0
    End If
  Next
End Sub

Sub ExplodeTopLevelProducts(ByVal rootProduct)
  Dim centerX, centerY
  centerX = -82.1
  centerY = -76

  Dim i, child, components(11), moveMatrix(11), dx, dy, dz, dist, unitX, unitY, factor
  For i = 1 To rootProduct.Products.Count
    Set child = rootProduct.Products.Item(i)
    child.Position.GetComponents components

    dx = components(9) - centerX
    dy = components(10) - centerY
    dist = Sqr((dx * dx) + (dy * dy))
    If dist < 1 Then
      unitX = 0
      unitY = 0
    Else
      unitX = dx / dist
      unitY = dy / dist
    End If

    factor = 130
    dz = 0
    Select Case i
      Case 4
        factor = 35
        dz = -55
      Case 12
        factor = 0
        dz = 180
      Case 1, 17, 19, 20
        factor = 175
        dz = 10
      Case 2
        factor = 0
        dz = 220
      Case 3, 9, 10, 11
        factor = 155
        dz = -65
      Case 13, 14, 15, 16, 18
        factor = 165
        dz = 30
      Case 6, 7, 8
        factor = 120
        dz = -110
      Case Else
        factor = 110
        dz = 30
    End Select

    If dist < 1 Then
      dz = dz + 70
    End If

    If IsAxisExplodedPart(i) Then
      SetAxisDirection i, components, dx, dy, unitX, unitY
    End If

    factor = factor * explosionScale
    dz = dz * explosionScale

    moveMatrix(0) = 1
    moveMatrix(1) = 0
    moveMatrix(2) = 0
    moveMatrix(3) = 0
    moveMatrix(4) = 1
    moveMatrix(5) = 0
    moveMatrix(6) = 0
    moveMatrix(7) = 0
    moveMatrix(8) = 1
    moveMatrix(9) = unitX * factor
    moveMatrix(10) = unitY * factor
    moveMatrix(11) = dz

    On Error Resume Next
    child.Move.Apply moveMatrix
    If Err.Number <> 0 Then
      WScript.Echo "WARN: Could not move " & child.Name & ": " & Err.Description
      Err.Clear
    End If
    On Error GoTo 0
  Next
End Sub

Function IsAxisExplodedPart(ByVal index)
  Select Case index
    Case 1, 2, 12, 17, 19, 20
      IsAxisExplodedPart = True
    Case Else
      IsAxisExplodedPart = False
  End Select
End Function

Sub SetAxisDirection(ByVal index, ByRef components, ByVal dx, ByVal dy, ByRef unitX, ByRef unitY)
  Dim ax, ay, dot
  Select Case index
    Case 1, 17, 19, 20
      ax = components(0)
      ay = components(1)
      dot = (ax * dx) + (ay * dy)
      If dot < 0 Then
        ax = -ax
        ay = -ay
      End If
      unitX = ax
      unitY = ay
    Case Else
      unitX = 0
      unitY = 0
  End Select
End Sub

Function CreateExplodedMultiViewDrawing(ByVal product)
  Dim doc
  Set doc = CATIA.Documents.Add("Drawing")
  doc.Standard = CAT_ISO

  Dim sheet
  Set sheet = doc.Sheets.Item(1)
  sheet.PaperSize = CAT_PAPER_A3
  sheet.Orientation = CAT_PAPER_LANDSCAPE
  sheet.ProjectionMethod = CAT_FIRST_ANGLE
  sheet.Scale = 0.12

  Dim views
  Set views = sheet.Views

  AddOrthographicView views, product, "Front view", 170, 145, 0.12, 1, 0, 0, 0, 0, 1
  AddOrthographicView views, product, "Right view", 270, 145, 0.12, 0, 1, 0, 0, 0, 1
  AddOrthographicView views, product, "Left view", 70, 145, 0.12, 0, -1, 0, 0, 0, 1
  AddOrthographicView views, product, "Top view", 170, 230, 0.12, 1, 0, 0, 0, 1, 0
  AddOrthographicView views, product, "Bottom view", 170, 60, 0.12, 1, 0, 0, 0, -1, 0
  AddOrthographicView views, product, "Rear view", 365, 145, 0.12, -1, 0, 0, 0, 0, 1
  AddIsometricView views, product, "Isometric view", 350, 235, 0.12

  sheet.ForceUpdate
  doc.Update
  Set CreateExplodedMultiViewDrawing = doc
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
