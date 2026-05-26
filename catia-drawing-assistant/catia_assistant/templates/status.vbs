Option Explicit
Dim CATIA
On Error Resume Next
Set CATIA = GetObject(, "CATIA.Application")
If Err.Number <> 0 Or CATIA Is Nothing Then
  WScript.Echo "ERROR: Cannot connect to a running CATIA session."
  WScript.Quit 1
End If
On Error GoTo 0

WScript.Echo "CATIA=" & CATIA.Name
WScript.Echo "Documents=" & CATIA.Documents.Count
Dim i, doc
For i = 1 To CATIA.Documents.Count
  Set doc = CATIA.Documents.Item(i)
  WScript.Echo i & " " & TypeName(doc) & " " & doc.Name
Next
