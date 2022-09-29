import nigui, sequtils, os, strutils, regex

app.init()

var dialogPath: string
var window = newWindow("Penesticus")


# ====== CORE OPERATIONS =========

#----- OP ON FILES -------
proc allFilesInDir(path:string):seq[string] = toSeq(walkFiles(path & "*"))
proc renameFile(pathToFile, newName: string) = 
  var (dir, _, ext) = splitFile(pathToFile)
  moveFile(pathToFile, dir & "\\" & newName & ext)
proc renameFileRegex(pathToFile, newName: string) = 
  var (dir, _, _) = splitFile(pathToFile)
  moveFile(pathToFile, dir & "\\" & newName)  
proc changeExt(pathToFile, newExt: string) = 
  var (dir, name, _) = splitFile(pathToFile)
  moveFile(pathToFile, dir & "\\" & name & newExt)
proc renameFileWtihExt(pathToFile, newName, newExt: string) = 
  var (dir, _, _) = splitFile(pathToFile)
  moveFile(pathToFile, dir & "\\" & newName & newExt)
proc trimNameLast(pathToFile: string, n: int): string = 
  var (_, name, _) = splitFile(pathToFile)
  name.delete(len(name)-n..len(name)-1)
  result = name
proc trimNameFirst(pathToFile: string, n: int): string = 
  var (_, name, _) = splitFile(pathToFile)
  name.delete(0..n-1)
  result = name
proc addPrefix(pathToFile, prefix: string): string =
  var (_, name, _) = splitFile(pathToFile)
  result = prefix & name
proc addSuffix*(pathToFile, suffix: string): string =
  var (_, name, _) = splitFile(pathToFile)
  result = name & suffix 
proc regexEx*(pathToFile, expression, by: string): string = 
  var (_, name, ext) = splitFile(pathToFile)
  let fullFile = name & ext
  fullFile.replace(re(expression), by)
proc getFileName(pathToFile: string): string = 
  var (_, name, _) = splitFile(pathToFile)
  result = name
#----- OP ON FILES -------

#----- OP UI -------
proc addSuffixUI(name, suffix: string): string = name & suffix
proc addPrefixUI(name, prefix: string): string = prefix & name
proc trimNameFirstUI(name: var string, n: int): string = 
  name.delete(0..n-1)
  result = name
proc trimNameLastUI(name: var string, n: int): string =
  var extPos = searchExtPos(name)
  if extPos == -1:
    name.delete(len(name)-n..len(name)-1)
    result = name
  else:
    var nWExt = name
    var ext = nWExt[extPos..len(nWExt)-1]
    nWExt.delete(extPos..len(nWExt)-1)
    if n > len(nWExt):
      discard
    else:
     nWExt.delete(len(nWExt)-n..len(nWExt)-1)
     result = nWExt & ext
proc changeExtUI(name, ext: string): string = changeFileExt(name, ext)
proc regexExUI(name, expression, by: string): string = 
 result = name.replace(re(expression), by)
#----- OP UI -------

# ====== CORE OPERATIONS =========


window.width = 600.scaleToDpi
window.height = 400.scaleToDpi


window.onResize = proc(event: ResizeEvent) = 
  window.width = 600.scaleToDpi
  window.height = 400.scaleToDpi

var container = newLayoutContainer(Layout_Vertical)
window.add(container)

var comboBox = newComboBox(@["NumsInc", "NumsDec", "Trim First", "Trim Last", "Prefix", "Suffix", "Ext", "Regex"])
comboBox.widthMode = WidthMode_Expand
container.add(comboBox)


#------- ACTION FRAME ---------

var containerAction = newLayoutContainer(Layout_Vertical)
containerAction.frame = newFrame()

var textBoxRegex = newTextBox()
textBoxRegex.placeholder = "Type your RE here"
textBoxRegex.visible = false
containerAction.add(textBoxRegex)

var textBoxAction = newTextBox()
textBoxAction.visible = false
containerAction.add(textBoxAction)

var uiShowCon = newLayoutContainer(Layout_Horizontal)
uiShowCon.spacing = 10

var textBox = newTextBox("test.txt")
textBox.width = 100
uiShowCon.add(textBox)

var label = newLabel("test.txt")
label.widthMode = WidthMode_Expand
uiShowCon.add(label)

containerAction.add(uiShowCon)

container.add(containerAction)

#--------- ACTION FRAME ---------


# ------------- BUTTON --------------

var containerBT = newLayoutContainer(Layout_Horizontal)
containerBT.spacing= 382
containerBT.frame = newFrame()

var buttonSD = newButton("Select Directory ...")
containerBT.add(buttonSD)

var buttonR = newButton("Rename")
buttonR.enabled = false
containerBT.add(buttonR)

container.add(containerBT)

# ----------- BUTTON -------------

#--------- FILES -------------
var textArea = newTextArea()
container.add(textArea)

var labelCount = newLabel("0")
container.add(labelCount)

var progressStatus = newLabel("---")
container.add(progressStatus)
#--------- FILES -------------

#--------- UI ACTIONS ---------

#=== internal ===
proc UIChanges() = 
 var tText = textBox.text
 if len(tText) == 0:
   discard
 else:
  case comboBox.index:
  of 0:
    label.text = "1..n " & tText  
  of 1: 
    label.text = "n..1 " & tText   
  of 2:
   if textBoxAction.text == "":
    label.text = trimNameFirstUI(tText, 0)
   else:
    try:
     let n = parseInt(textBoxAction.text)
     if n > len(tText):
       discard
     else:
      label.text = trimNameFirstUI(tText, n)
    except: window.alert(getCurrentExceptionMsg())
  of 3:
   if textBoxAction.text == "" or textBoxAction.text == "0":
    label.text = trimNameFirstUI(tText, 0)
   else:
    try:
     let n = parseInt(textBoxAction.text) 
     if n > len(tText):
      discard
     else:
      label.text = trimNameLastUI(tText, n)
    except: window.alert(getCurrentExceptionMsg())
  of 4:
   label.text = addPrefixUI(tText, textBoxAction.text)
  of 5:
   label.text = addSuffixUI(tText, textBoxAction.text)
  of 6:
   label.text = changeExtUI(tText, textBoxAction.text)
  of 7:
   try:
    label.text = regexExUI(tText, textBoxRegex.text, textBoxAction.text)
   except: window.alert(getCurrentExceptionMsg())
  else:
   discard
#=== internal ===   

comboBox.onChange = proc(event: ComboBoxChangeEvent) = 
 textBoxAction.text=""
 textBoxRegex.text=""
 textBoxAction.visible = false
 textBoxRegex.visible = false
 case comboBox.index:
  of 0:
    discard
  of 1:
    discard
  of 2:
   textBoxAction.text="1"
   textBoxAction.visible = true
  of 3:
   textBoxAction.text="1"
   textBoxAction.visible = true
  of 4:
    textBoxAction.placeholder="Type your prefix here"
    textBoxAction.visible = true
  of 5:
    textBoxAction.placeholder="Type your suffix here"
    textBoxAction.visible = true
  of 6:
    textBoxAction.placeholder="Type new ext here"
    textBoxAction.visible = true
  of 7:
    textBoxRegex.visible = true
    textBoxAction.placeholder="Replace by:"
    textBoxAction.visible = true
  else:
   discard

textBoxRegex.onTextChange = proc(event: TextChangeEvent) =
 UIChanges()

textBoxAction.onTextChange = proc(event: TextChangeEvent) =
 UIChanges()

textBox.onTextChange = proc(event: TextChangeEvent) = 
 UIChanges()

buttonR.onClick = proc(event: ClickEvent) =
  if textArea.text == "": 
    window.alert($comboBox.index)
  else:
   var action = textBoxAction.text
   var sT = split(textArea.text, "\r\n")
   sT.delete(len(sT)-1)
   var sTLen = len(sT)
   case comboBox.index:
   of 0:
     for idx, f in sT:
       renameFile(f, $idx & " " & getFileName(f))
   of 1:
     for idx, f in sT:
       var n = len(sT)-idx
       renameFile(f, $n & " " & getFileName(f))
   of 2:
    try: 
     let n = parseInt(action)
     for idx, f in sT:
      var nN = trimNameFirst(f, n)
      renameFile(f, nN)
      progressStatus.text = $idx & " / " & $sTLen
    except: window.alert(getCurrentExceptionMsg())
   of 3:
    try: 
     let n = parseInt(action)
     for idx, f in sT:
      var nN = trimNameLast(f, n)
      renameFile(f, nN)
      progressStatus.text = $idx & " / " & $sTLen
    except: window.alert(getCurrentExceptionMsg())
   of 4:
     try:
      for idx, f in sT:
       renameFile(f, addPrefix(f, action))
       progressStatus.text = $idx & " / " & $sTLen
     except: window.alert(getCurrentExceptionMsg())
   of 5:
     try:
      for idx, f in sT:
       renameFile(f, addSuffix(f, action))
       progressStatus.text = $idx & " / " & $sTLen
     except: window.alert(getCurrentExceptionMsg())
   of 6:
     try:
      for idx, f in sT:
       changeExt(f, action)
       progressStatus.text = $idx & " / " & $sTLen
     except: window.alert(getCurrentExceptionMsg())
   of 7:
     try:
      for idx, f in sT:
       renameFileRegex(f, (regexEx(f, textBoxRegex.text, action)))
       progressStatus.text = $idx & " / " & $sTLen
     except: window.alert(getCurrentExceptionMsg())
   else:
     discard
  progressStatus.text = "Finished"
  textArea.text=""
  var files = allFilesInDir(dialogPath & "/")
  for f in files:
        textArea.addLine(f) 
  buttonR.enabled = false

buttonSD.onClick = proc(event: ClickEvent) =
  textArea.text = ""
  labelCount.text = "0"
  var dialog = SelectDirectoryDialog()
  dialog.title = "Select Directory"
  dialog.run()
  if dialog.selectedDirectory == "":
    textArea.addLine("No directory selected")
  else:
    var files = allFilesInDir(dialog.selectedDirectory & "/")
    if len(files) == 0:
      textArea.addLine("No files in directory")
    else:
      for f in files:
        textArea.addLine(f)
    dialogPath = dialog.selectedDirectory
    labelCount.text = dialog.selectedDirectory & ": " & $len(files) & " files"
    progressStatus.text = "0 / " & $len(files) 
    buttonR.enabled = true
  
#--------- UI ACTIONS ---------

window.show()
app.run()
