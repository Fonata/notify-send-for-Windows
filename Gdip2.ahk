class Gdip
{
	__New()
	{
		if !DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("LoadLibrary", "str", "gdiplus")
		VarSetCapacity(si, (A_PtrSize = 8) ? 24 : 16, 0), si := Chr(1)
		DllCall("gdiplus\GdiplusStartup", "uptr*", pToken, "uptr", &si, "uint", 0)
		this.pToken := pToken
	}
	
	__Delete()
	{
		this.Dispose()
	}
	
	Dispose()
	{
		DllCall("gdiplus\GdiplusShutdown", "uptr", this.pToken)
		if hModule := DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("FreeLibrary", "uptr", hModule)
	}
	
	BitmapFromScreen(params*)
	{
		bitmap1 := new Gdip.Bitmap()
		/*
		c := params.MaxIndex()
		if (c = 1)
			bitmap1.Pointer := bitmap1.BitmapFromScreen(params[1])
		else if (c = 2)
			bitmap1.Pointer := bitmap1.BitmapFromScreen(params[1], params[2])
		else if (c = 4)
			bitmap1.Pointer := bitmap1.BitmapFromScreen(params[1], params[2], params[3], params[4])
		else if (c = 5)
			bitmap1.Pointer := bitmap1.BitmapFromScreen(params[1], params[2], params[3], params[4], params[5])
		*/
		bitmap1.Pointer := bitmap1.BitmapFromScreen(params*)
		return bitmap1
	}
	
	BitmapFromZip(zipObj, file)
	{
		bitmap1 := new Gdip.Bitmap()
		bitmap1.Pointer := bitmap1.BitmapFromZip(zipObj, file)
		return bitmap1
	}
	
	BitmapFromFile(file)
	{
		bitmap1 := new Gdip.Bitmap()
		bitmap1.Pointer := bitmap1.BitmapFromFile(file)
		return bitmap1
	}
	
	class Brush
	{
		;ARGB
		;R, G, B
		;A, R, G, B
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 1)
			{
				ARGB := params[1]
			}
			else if (c = 3)
			{
				ARGB := (255 << 24) | (params[1] << 16) | (params[2] << 8) | params[3]
			}
			else if (c = 4)
			{
				ARGB := (params[1] << 24) | (params[2] << 16) | (params[3] << 8) | params[4]
			}
			else
				throw "Incorrect number of parameters for Brush.New()"
			this.Pointer := this.CreateSolid(ARGB)
		}
		
		__Delete()
		{
			this.Dispose()
		}
		
		Dispose()
		{
			return DllCall("gdiplus\GdipDeleteBrush", "uptr", this.Pointer)
		}
		
		CreateSolid(ARGB)
		{
			DllCall("gdiplus\GdipCreateSolidFill", "uint", ARGB, "uptr*", pBrush)
			return pBrush
		}
	}
	
	class Point
	{
		X := null
		Y := null
		__New(x, y)
		{
			this.X := x
			this.Y := y
		}
	}

	class Size
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 2)
			{
				if (IsObject(params[1]))
				{
					this.Width := Round(params[1].Width * params[2])
					this.Height := Round(params[1].Height * params[2])
				}
				else
				{
					this.Width := params[1]
					this.Height := params[2]
				}
			}
			else
				throw "Incorrect number of parameters for Size.New()"
		}
	}
	
	class Window
	{
		__New(params*)
		{
			;size
			;point, size
			c := params.MaxIndex()
			if (!c)
			{
			}
			else if (c = 1)
			{
				size := params[1]
				point := new Gdip.Point(0, 0)
			}
			else if (c = 2)
			{
				point := params[1]
				size := params[2]
			}
			else
				throw "Incorrect number of parameters for Window.New()"

			this.hwnd := DllCall("CreateWindowEx", "uint", 0x80088, "str", "#32770", "ptr", 0, "uint", 0x940A0000
			,"int", point.X, "int", point.Y, "int", size.Width, "int", size.Height, "uptr", 0, "uptr", 0, "uptr", 0, "uptr", 0)
				
			this.X := point.X
			this.Y := point.Y
			this.Point := new Gdip.Point(point.X, point.Y)
			this.Width := size.Width
			this.Height := size.Height
			this.Size := new Gdip.Size(size.Width, size.Height)
			this.Alpha := 255
		}
		
		IsHover(mousePoint, point, size)
		{
			return mousePoint.X >= this.X + point.X && mousePoint.X <= this.X + point.X + size.Width && mousePoint.Y >= this.Y + point.Y && mousePoint.Y <= this.Y + point.Y + size.Height
		}
		
		Drag()
		{
			CoordMode, Mouse, Screen
			MouseGetPos,,, win
			if (win = this.hwnd)
				PostMessage, 0xA1, 2,,, % "ahk_id " this.hwnd
		}

		;obj
		;obj, point
		;obj, point, size
		;obj, point, size, alpha
		Update(params*)
		{
			c := params.MaxIndex()
			obj := params[1]
			alpha := 255
			if (c = 1)
			{
				WinGetPos, x, y, w, h, % "ahk_id " this.hwnd
				point := new Gdip.Point(x, y)
				size := obj
			}
			else if (c = 2)
			{
				point := params[2]
				size := obj
			}
			else if (c = 3)
			{
				point := params[2]
				size := params[3]
			}
			else if (c = 4)
			{
				point := params[2]
				size := params[3]
				alpha := params[4]
			}
			else
				throw "Incorrect number of parameters for Window.Update()"
				
			CoordMode, Mouse, Screen
			MouseGetPos, mx, my
			mousePoint := new Gdip.Point(mx, my)

			for k, shape in obj.Shapes
			{
				if (this.IsHover(mousePoint, shape.Point, shape.Size))
				{
					otherHit := false
					loop, % obj.Shapes.MaxIndex() - k
					{
						k2 := k + 1
						shape2 := obj.Shapes[k2]
						if (shape2 != shape && this.IsHover(mousePoint, shape2.Point, shape2.Size))
						{
							otherHit := true
							break
						}
					}

					if (!otherHit)
					{
						if (shape != this.hoverShape)
						{
							shape2 := this.hoverShape
							if (IsObject(shape2.hoverOut))
								hoverOutFn := shape2.hoverOut.function, hoverOutParams := shape2.hoverOut.parameters
							else
								hoverOutFn := shape2.hoverOut, hoverOutParams := {}
								
							if (IsFunc(hoverOutFn))
							{
								hoverOutFn.(shape2, { x: mx - this.X - shape2.X, y: my - this.Y - shap2e.Y }, hoverOutParams)
							}
							this.hoverShape := shape
						}
					
						lButton := GetKeyState("LButton")
						this.hoverShape := shape
						;tooltip, % shape.Shape
						if (lButton && shape.click = "Drag")
						{
							this.Drag()
						}
						else
						{
							if (IsObject(shape.hoverIn))
								hoverInFn := shape.hoverIn.function, hoverInParams := shape.hoverIn.parameters
							else
								hoverInFn := shape.hoverIn, hoverInParams := {}
								
							if (IsObject(shape.click))
								clickFn := shape.click.function, clickParamas := shape.click.parameters
							else
								clickFn := shape.click, clickParams := {}
								
							if (lButton && IsFunc(clickFn))
							{
								clickFn.(shape, { x: mx - this.X - shape.X, y: my - this.Y - shape.Y }, clickParamas)
							}
							else if (IsFunc(hoverInFn))
							{
								hoverInFn.(shape, { x: mx - this.X - shape.X, y: my - this.Y - shape.Y }, hoverInParams)
							}
						}
					}
				}
				else if (shape = this.hoverShape)
				{
					if (IsObject(shape.hoverOut))
						hoverOutFn := shape.hoverOut.function, hoverOutParams := shape.hoverOut.parameters
					else
						hoverOutFn := shape.hoverOut, hoverOutParams := {}
						
					if (IsFunc(hoverOutFn))
					{
						hoverOutFn.(shape, { x: mx - this.X - shape.X, y: my - this.Y - shape.Y }, hoverOutParams)
					}
					this.hoverShape := 0
				}
			}
			this.X := point.X
			this.Y := point.Y
			this.Point := new Gdip.Point(point.X, point.Y)
			this.Width := size.Width
			this.Height := size.Height
			this.Size := new Gdip.Size(size.Width, size.Height)
			this.Alpha := alpha

			return this.UpdateLayeredWindow(this.hwnd, obj.hdc, point.X, point.Y, size.Width, size.Height, alpha)
		}
		
		UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", alpha=255)
		{
			if ((x != "") && (y != ""))
				VarSetCapacity(pt, 8), NumPut(x, pt, 0, "uint"), NumPut(y, pt, 4, "uint")

			if ((w = "") || (h = ""))
				WinGetPos,,, w, h, ahk_id %hwnd%
				
			return DllCall("UpdateLayeredWindow", "uptr", hwnd, "uptr", 0, "uptr", ((x = "") && (y = "")) ? 0 : &pt, "int64*", w|h<<32, "uptr", hdc, "int64*", 0, "uint", 0, "uint*", alpha<<16|1<<24, "uint", 2)
		}
	}
	
	class Zip
	{
		;file
		__New(params*)
		{
			c := params.MaxIndex()
			if (c = 1)
			{
				file := FileOpen(params[1], "r")
				this.Handle := file
				this.Files := this.ListFiles(file)
			}
			else
				throw "Incorrect number of parameters for Zip.New()"
		}
		
		Dispose()
		{
			this.Handle.Close()
			this.Handle := ""
			this.Files := ""
		}
		
		__Delete()
		{
			this.Dispose()
		}
		
		GetIndex(file)
		{
			index := -1
			for k, v in this.Files
			{
				if (v.FileName = file)
				{
					index := k
					break
				}
			}
			return index
		}
		
		ListFiles(file)
		{
			fileSize := file.Length
			
			array := []
			;array := {}
			file.Position := fileSize - 46
			
			i := 0
			while(i < 1000 || file.Position <= 5)
			{
				signature := file.ReadUInt()
				if (signature = 0x02014b50)
				{
					i := 0
					file.Seek(16, 1)
					compressedSize := file.ReadInt()
					uncompressedSize := file.ReadInt()
					fileNameLength := file.ReadChar()
					file.Seek(13, 1)
					offset := file.ReadInt()
					fileName := file.Read(fileNameLength)
					if (SubStr(fileName, 0, 1) != "/")
					{
						position := file.Position
						file.Seek(offset, 0)
						localHeader := file.ReadInt()
						if (localHeader = 0x04034b50)
						{
							file.Seek(22, 1)
							fileNameLength := file.ReadChar()
							extraFieldLength := file.ReadChar()
							file.Seek(2, 1)
							fileName := file.Read(fileNameLength)
							StringReplace, fileName, fileName, /, \, All
							extraField := file.Read(extraFieldLength)
							offset := file.Position
							array.Insert({ FileName: fileName, Offset: offset, CompressedSize: compressedSize })
						}
						file.Seek(position, 0)
					}
					pos := -1 * (fileNameLength + 42)
					file.Seek(pos, 1)
				}
				file.Seek(-5, 1)
				i++
			}
			return array
		}
	}
	
	class Bitmap
	{
		;width, height
		;width, height, format
		__New(params*)
		{
			c := params.MaxIndex()
			if (!c)
			{
			}
			else if (c = 2)
			{
				this.Pointer := this.CreateBitmap(params[1], params[2])
			}
			else if (c = 3)
			{
				this.Pointer := this.CreateBitmap(params[1], params[2], params[3])
			}
			else
				throw "Incorrect number of parameters for Bitmap.New()"
			this.Width := this.GetImageWidth(this.Pointer)
			this.Height := this.GetImageHeight(this.Pointer)
			this.Size := new Gdip.Size(this.Width, this.Height)
			this._opacity := 1
			this._matrix := [[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,this._opacity,0],[0,0,0,0,1]]
			this._imageAttr := obj.SetImageAttributesColorMatrix(this._matrix)
		}
		
		Opacity[]
		{
			get {
				return this._opacity
			}
			set {
				this._opacity := value
				;obj := new Gdip.Object()
				if (this._matrix)
				{
					;MsgBox, here 1
					;this._matrix := [[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,value,0],[0,0,0,0,1]]
					matrix := this._matrix
					;MsgBox, % matrix[4, 4]
					matrix[4, 4] := this._opacity
					;MsgBox, % matrix[4, 4]
					this._matrix := matrix
					this.ImageAttr := this._matrix
					;obj.SetImageAttributesColorMatrix(this._matrix)
				}
				else
				{
					;MsgBox, % this._opacity
					this._matrix := [[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,this._opacity,0],[0,0,0,0,1]]
					this.ImageAttr := this._matrix
					;this.ImageAttr :=  obj.SetImageAttributesColorMatrix(this._matrix)
				}
			}
		}
		
		ImageAttr[]
		{
			get {
				return this._imageAttr
			}
			set {
				this._matrix := value
				;Tooltip, % this._matrix[4, 4]
				obj := new Gdip.Object()
				;matrix := (matrix + 0 >= 0) ? [[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,matrix,0],[0,0,0,0,1]] : matrix
				this._imageAttr := obj.SetImageAttributesColorMatrix(this._matrix)
			}
		}
		
		_pointer := 0
		Pointer[]
		{
			get {
				return this._pointer
			}
			set {
				this.Width := this.GetImageWidth(value)
				this.Height := this.GetImageHeight(value)
				this.Size := new Gdip.Size(this.Width, this.Height)
				this._pointer := value
			}
		}
		
		Width[]
		{
			get { 
				return this.Width 
			}
		}
		
		Height[]
		{
			get {
				return this.Height
			}
		}
		
		Size[]
		{
			get {
				return this.Size
			}
		}
		
		__Delete()
		{
			this.Dispose()
		}
		
		Dispose()
		{
			this.DisposeImage(this.Pointer)
			this.Pointer := ""

			if (this.ImageAttr)
			{
				obj := new Gdip.Object()
				obj.DisposeImageAttributes(this.ImageAttr)
			}
		}
		
		DisposeImage(pBitmap)
		{
			return DllCall("gdiplus\GdipDisposeImage", "uptr", pBitmap)
		}
		
		DeleteGraphics(pGraphics)
		{
		   return DllCall("gdiplus\GdipDeleteGraphics", "uptr", pGraphics)
		}
		
		BitmapFromFile(file)
		{
			DllCall("gdiplus\GdipCreateBitmapFromFile", "uptr", &file, "uptr*", pBitmap)
			return pBitmap
		}
		
		BitmapFromZip(zipObj, file)
		{
			pBitmap := 0
			if (file + 0 > 0)
			{
				pBitmap := this.BitmapFromStream(zipObj.Handle, zipObj.Files[file].Offset, zipObj.Files[file].CompressedSize)
			}
			else
			{
				for k, v in zipObj.Files
				{
					if (v.FileName = file)
					{
						pBitmap := this.BitmapFromStream(zipObj.Handle, v.Offset, v.CompressedSize)
						break
					}
				}
			}
			return pBitmap
		}
		
		BitmapFromStream(file, start, size)
		{
			file.Position := start
			file.RawRead(memoryFile, size)
			hData := DllCall("GlobalAlloc", "uint", 2, "ptr", size, "ptr")
			pData := DllCall("GlobalLock", "ptr", hData, "ptr")
			DllCall("RtlMoveMemory", "ptr", pData, "ptr", &memoryFile, "ptr", size)
			unlock := DllCall("GlobalUnlock", "ptr", hData)
			stream := DllCall("ole32\CreateStreamOnHGlobal", "ptr", hData, "int", 1, "uptr*", pStream)
			DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr", pStream, "uptr*", pBitmap)
			ObjRelease(pStream)
			return pBitmap
		}
		
		;screenNumber (0 default)
		;screenNumber, raster
		;{ hwnd: hwnd }
		;{ hwnd: hwnd }, raster
		;x, y, w, h
		;x, y, w, h, raster
		BitmapFromScreen(params*)
		{
			c := params.MaxIndex()
			obj := new Gdip.Object()
			
			if (c = 1 || c = 2)
			{
				if (IsObject(params[1]))
				{
					hwnd := params[1].hwnd
					if !WinExist( "ahk_id " hwnd)
						return -2
					x := 0, y := 0
					WinGetPos,,, w, h, ahk_id %hwnd%
					hhdc := obj.GetDCEx(hwnd, 3)
				}
				else
				{
					if (screen = 0)
					{
						Sysget, x, 76
						Sysget, y, 77	
						Sysget, w, 78
						Sysget, h, 79
					}
					else
					{
						Sysget, M, Monitor, % params[1]
						x := MLeft, y := MTop, w := MRight-MLeft, h := MBottom-MTop
					}
				}
				raster := params[2] ? params[2] : ""
			}
			else if (c = 4 || c = 5)
			{
				x := params[1], y := params[2], w := params[3], h := params[4]
				raster := params[5] ? params[5] : ""
			}
			else
				throw "Incorrect number of parameters for Bitmap.BitmapFromScreen()"

			chdc := obj.CreateCompatibleDC()
			hbm := obj.CreateDIBSection(w, h, chdc)
			obm := obj.SelectObject(chdc, hbm)
			hhdc := hhdc ? hhdc : obj.GetDC()
			obj.BitBlt(chdc, 0, 0, w, h, hhdc, x, y, raster)
			obj.ReleaseDC(hhdc)
			
			pBitmap := this.CreateBitmapFromHBITMAP(hbm)
			obj.SelectObject(chdc, obm)
			obj.DeleteObject(hbm)
			obj.DeleteDC(hhdc)
			obj.DeleteDC(chdc)
			return pBitmap
		}

		CreateBitmap(width, height, format=0x26200A)
		{
			DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", width, "int", height, "int", 0, "int", format, "uptr", 0, "uptr*", pBitmap)
			return pBitmap
		}
		
		CreateBitmapFromHBITMAP(hBitmap, palette=0)
		{
			DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "uptr", hBitmap, "uptr", palette, "uptr*", pBitmap)
			return pBitmap
		}
		
		CloneBitmapArea(point, size, format=0x26200A)
		{
			bitmap1 := new Gdip.Bitmap()
			bitmap1.Pointer := this._CloneBitmapArea(this.Pointer, point.X, point.Y, size.Width, size.Height, format)
			return bitmap1
		}

		_CloneBitmapArea(pBitmap, x, y, w, h, format=0x26200A)
		{
			DllCall("gdiplus\GdipCloneBitmapArea", "float", x, "float", y, "float", w, "float", h, "int", format, "uptr", pBitmap, "uptr*", pBitmapDest)
			return pBitmapDest
		}
		
		GraphicsFromImage(pBitmap)
		{
			DllCall("gdiplus\GdipGetImageGraphicsContext", "uptr", pBitmap, "uptr*", pGraphics)
			return pGraphics
		}
		
		SaveToFile(output, quality=75)
		{
			return this._SaveBitmapToFile(this.Pointer, output, quality)
		}
		
		_SaveBitmapToFile(pBitmap, output, quality=75)
		{
			SplitPath, output,,, extension
			if extension not in BMP,DIB,RLE,JPG,JPEG,JPE,JFIF,GIF,TIF,TIFF,PNG
				return -1
			extension := "." extension
			
			DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize)
			VarSetCapacity(ci, nSize)
			DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "uptr", &ci)
			if !(nCount && nSize)
				return -2
				
			Loop, %nCount%
			{
				idx := 104*(A_Index-1)
				sString := StrGet(NumGet(ci, idx+56), "UTF-16")
				if !InStr(sString, "*" extension)
					continue
				pCodec := &ci+idx
				break
			}
			
			if !pCodec
				return -3
				
			if (quality != 75)
			{
				if Extension in .JPG,.JPEG,.JPE,.JFIF
				{
					quality := (quality < 0) ? 0 : (quality > 100) ? 100 : quality
					DllCall("gdiplus\GdipGetEncoderParameterListSize", "uptr", pBitmap, "uptr", pCodec, "uint*", nSize)
					VarSetCapacity(EncoderParameters, nSize, 0)
					DllCall("gdiplus\GdipGetEncoderParameterList", "uptr", pBitmap, "uptr", pCodec, "uint", nSize, "uptr", &EncoderParameters)
					Loop, % NumGet(EncoderParameters, "uint")
					{
						pad := (A_PtrSize = 8) ? 4 : 0
						offset := 32 * (A_Index-1) + 4 + pad
						if (NumGet(EncoderParameters, offset+16, "uint") = 1) && (NumGet(EncoderParameters, offset+20, "uint") = 6)
						{
							encoderParams := offset+&EncoderParameters - pad - 4
							NumPut(quality, NumGet(NumPut(4, NumPut(1, encoderParams+0)+20, "uint")), "uint")
							break
						}
					}      
				}
			}
			E := DllCall("gdiplus\GdipSaveImageToFile", "uptr", pBitmap, "uptr", &output, "uptr", pCodec, "uint", encoderParams ? encoderParams : 0)
			return E ? -5 : 0
		}
		
		;Scale
		;Width, Height
		Resize(params*)
		{
			c := params.MaxIndex()
			if (c = 1)
			{
				size := new Gdip.Size(this.Size, params[1])
			}
			else if (c = 2)
			{
				size := new Gdip.Size(params[1], params[2])
			}
			else
				throw "Incorrect number of parameters for Bitmap.Resize()"
			
			matrix := this._matrix
			imageAttr := this._imageAttr
			this.ImageAttr := [[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,1,0],[0,0,0,0,1]]
			pBitmap := this.CreateBitmap(size.Width, size.Height)
			pGraphics := this.GraphicsFromImage(pBitmap)
			obj := new Gdip.Object()
			E := obj.DrawImage(pGraphics, this, new Gdip.Point(0, 0), size)
			this.DisposeImage(this.Pointer)
			this.DeleteGraphics(pGraphics)
			this.Pointer := pBitmap
			this.Size := size
			this.Width := size.Width
			this.Height := size.Height
			this._imageAttr := imageAttr
			this._matrix := matrix
			return this
		}
		
		/*
		ApplyColorMatrix(matrix)
		{
			pBitmap := this.CreateBitmap(this.Width, this.Height)
			pGraphics := this.GraphicsFromImage(pBitmap)
			obj := new Gdip.Object()
			matrix := (matrix + 0 >= 0) ? [[1,0,0,0,0],[0,1,0,0,0],[0,0,1,0,0],[0,0,0,matrix,0],[0,0,0,0,1]] : matrix
			imageAttr := obj.SetImageAttributesColorMatrix(matrix)
			E := obj._DrawImage(pGraphics, this.Pointer, 0, 0, this.Width, this.Height, 0, 0, this.Width, this.Height, imageAttr)
			obj.DisposeImageAttributes(imageAttr)
			this.DisposeImage(this.Pointer)
			this.DeleteGraphics(pGraphics)
			this.Pointer := pBitmap
			return this
		}
		*/
		
		GetImageWidth(pBitmap)
		{
			DllCall("gdiplus\GdipGetImageWidth", "uptr", pBitmap, "uint*", width)
			return width
		}
		
		GetImageHeight(pBitmap)
		{
			DllCall("gdiplus\GdipGetImageHeight", "uptr", pBitmap, "uint*", height)
			return height
		}
	}
	
	class Shape extends Gdip.Timer
	{
		__New(shape, params*)
		{
			; rectangle,point,size,radius,borderWidth,fill,border
			if (shape = "Rectangle")
			{
				this.Shape := shape
				this.Point := params[1]
				this.Size := params[2]
				this.Radius := params[3] ? params[3] : 0
				this.BorderWidth := params[4]
				this.Brush := params[5]
				this.Border := params[6]
				;this.ImagAttr := params[7] ? params[7] : 1
			}
			else if (shape = "Image")
			{
				this.Shape := shape
				this._bitmap := params[1]
				this.Point := params[2]
				this.Size := this._bitmap.Size
				this.AnimateSize := this.Size
				this.AnimateWidth := this.AnimateSize.Width
				this.AnimateHeight := this.AnimateSize.Height
				this._imageAttr := this._bitmap.ImageAttr
				this._opacity  := this._bitmap.Opacity
			}
			else
				throw "Unrecognized shape in Shape.New - " shape
				
			this.X := this.Point.X
			this.Y := this.Point.Y
			this.Width := this.Size.Width
			this.Height := this.Size.Height
			this.Animating := false
		}
		
		Opacity[]
		{
			get {
				return this._opacity
			}
			set {
				this._bitmap.Opacity := 0.2
				this._opacity := 0.2
				;MsgBox, % this._opacity
			}
		}
		
		ImageAttr[]
		{
			get {
				return this._imageAttr
			}
			set {
				this.Bitmap.ImageAttr := value
				;MsgBox, % value
				this._imageAttr := this.Bitmap.ImageAttr
			}
		}
		
		Bitmap[]
		{
			get {
				return this._bitmap
			}
			set {
				;matrix := this._bitmap._matrix
				;opacity := this.Bitmap.Opacity
				;imageAttr := this._bitmap._imageAttr
				
				;bitmap1 := value
				
				;if (this._bitmap._opacity != 1)
				;		MsgBox, % this._bitmap._opacity
				;Tooltip, % this._bitmap._opacity
				
				;Tooltip, % opacity
				
				;this._bitmap._matrix := matrix
				;this.Bitmap.Opacity := opacity
				;Tooltip, % this._bitmap._opacity "`n" opacity
				;this._bitmap._imageAttr := _imageAttr
				
				;this._bitmap.ImageAttr := imageAttr
				;this.Size := this.bitmap1.Size
				;this.AnimateSize := this.Size
				;this.AnimateWidth := this.AnimateSize.Width
				;this.AnimateHeight := this.AnimateSize.Height
				
				;this._imageAttr := bitmap1.ImageAttr
				;this._opacity := bitmap1.Opacity
				
				this._bitmap := value
				;this.Point := params[2]
				this.Size := this._bitmap.Size
				this.AnimateSize := this.Size
				this.AnimateWidth := this.AnimateSize.Width
				this.AnimateHeight := this.AnimateSize.Height
				;this._imageAttr := this._bitmap.ImageAttr
				;this._opacity  := this._bitmap.Opacity
				;this._opacity := 0.2
				;this._bitmap.Opacity := 0.2
				
				;this._imageAttr := this._bitmap.ImagAttr
				;this._opacity := this._bitmap.Opacity
				;if (this._opacity != 1)
				;	Msgbox, % this._opacity
				;Tooltip, % this._opacity
			}
		}
		
		/*
		SlideUp(interval, animation)
		{
			;if (this.Animating)
			;	this.SetTimer(this._Animate, 0)
			this.Animating := true
			animation.animation := "SlideUp"
			animation.startTick := A_TickCount
			animation.startHeight := animation.startHeight ? animation.startHeight : this.Height
			animation.endHeight := animation.endHeight ? animation.endHeight : 0
			animation.time := animation.time ? animation.time : 500
			this.SetTimer(this._Animate, interval, animation)
		}
		
		SlideDown(interval, animation)
		{
			;if (this.Animating)
			;	this.SetTimer(this._Animate, 0)
			this.Animating := true
			animation.animation := "SlideDown"
			animation.startTick := A_TickCount
			animation.startHeight := animation.startHeight ? animation.startHeight : this.Height
			animation.time := animation.time ? animation.time : 500
			this.SetTimer(this._Animate, interval, animation)
		}
		*/
		
		Animate(interval, a)
		{
			this.Animating := true
			a.startTick := A_TickCount
			a.time := 500
			a.fromX := this.X
			a.fromY := this.Y
			a.toX := this.X
			a.toY := this.Y
			a.fromWidth := this.Width
			a.fromHeight := this.Height
			a.toWidth := this.Width
			a.toHeight := this.Height
			a.fromOpacity := this.Opacity
		}
		
		_Animate(params)
		{
			static i = 0
			for k, v in params
			{
				%k% := v
				;MsgBox, % k
			}
			;Tooltip, % i++
			
			if (A_TickCount - startTick >= time && this.Animating)
			{
				this.Size.Height := endHeight
				this.Height := endHeight
				this.Animating := false
				this.SetTimer(Func(A_ThisFunc), 0)
				onComplete.(parameters)
			}
			else
			{
				fraction := (A_TickCount - startTick) / time
				;tooltip, % fraction
				if (animation = "SlideUp")
				{
					if (this.Shape = "Rectangle")
					{
						currentHeight := startHeight - (fraction * (startHeight - endHeight))
						this.Size.Height := currentHeight
						this.Height := currentHeight
					}
					else if (this.Shape = "Image")
					{
						;MsgBox, here 77
					}
				}
				else if (animation = "SlideDown")
				{
					;MsGbox, slide down
					currentHeight := startHeight + (fraction * (endHeight - startHeight))
					this.Size.Height := currentHeight
					this.Height := currentHeight
				}
			}
		}
	}

	class Object extends Gdip.Timer
	{
		__New(params*)
		{
			c := params.MaxIndex()
			if (!c)
			{
			}
			else if (c = 1)
			{
				size := params[1]
				this.Width := size.Width
				this.Height := size.Height
				this.hBitmap := this.CreateDIBSection(this.Width, this.Height)
				this.hdc := this.CreateCompatibleDC()
				this.hgdiObj := this.SelectObject(this.hdc, this.hBitmap)
				this.pGraphics := this.GraphicsFromHDC(this.hdc)
				this.SetSmoothingMode(this.pGraphics, 4)
				this.DrawFrameObj := { "Function": 0, "Interval": 0, "ParamsObj": {} }
				this.Shapes := []
			}
			else
				throw "Incorrect number of parameters for Object.New()"
		}
		
		__Delete()
		{
			this.Dispose()
		}
		
		Dispose()
		{
			this.SelectObject(this.hdc, this.hgdiObj)
			this.DeleteObject(this.hBitmap)
			this.DeleteDC(this.hdc)
			this.DeleteGraphics(this.pGraphics)
			this.hdc := ""
			this.hgdiObj := ""
			this.hBitmap := ""
			this.pGraphics := ""
		}
		
		DrawFrame(function, interval, paramObj=0)
		{
			function := Func(function)
			this.DrawFrameObj := { "Function": function, "Interval": interval, "ParamsObj": paramObj }
			;MsgBox, % function.Name
			;function.(this, paramObj)
			;return this.SetTimer(function, interval, paramObj)
			this.SetTimer(this.base._DrawFrame, interval, paramObj)
		}
		
		_DrawFrame(function)
		{
			this.Clear()
			this.DrawFrameObj.Function.(this, this.DrawFrameObj.ParamsObj)
		}
		
		StopFrame()
		{
			E := this.SetTimer(this.base._DrawFrame)
			this.DrawFrameObj := { "Function": 0, "Interval": 0, "ParamsObj": {} }
			return E
		}
		
		CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
		{
			hdc2 := hdc ? hdc : this.GetDC()
			VarSetCapacity(bi, 40, 0)

			NumPut(w, bi, 4, "uint")
			NumPut(h, bi, 8, "uint")
			NumPut(40, bi, 0, "uint")
			NumPut(1, bi, 12, "ushort")
			NumPut(0, bi, 16, "uint")
			NumPut(bpp, bi, 14, "ushort")

			hBitmap := DllCall("CreateDIBSection", "uptr", hdc2, "uptr", &bi, "uint", 0, "uptr*", ppvBits, "uptr", 0, "uint", 0)

			if !hdc
				this.ReleaseDC(hdc2)
			return hBitmap
		}
		
		CreateCompatibleDC(hdc=0)
		{
			return DllCall("CreateCompatibleDC", "uptr", hdc)
		}

		SelectObject(hdc, hgdiObj)
		{
			return DllCall("SelectObject", "uptr", hdc, "uptr", hgdiObj)
		}
		
		GetDC(hwnd=0)
		{
			return DllCall("GetDC", "uptr", hwnd)
		}
		
		GetDCEx(hwnd, flags=0, hrgnClip=0)
		{
			return DllCall("GetDCEx", "uptr", hwnd, "uptr", hrgnClip, "int", flags)
		}
		
		ReleaseDC(hdc, hwnd=0)
		{
			return DllCall("ReleaseDC", "uptr", hwnd, "uptr", hdc)
		}
		
		DeleteObject(hgdiObj)
		{
			return DllCall("DeleteObject", "uptr", hgdiObj)
		}
		
		DeleteDC(hdc)
		{
			return DllCall("DeleteDC", "uptr", hdc)
		}
		
		DeleteGraphics(pGraphics)
		{
			return DllCall("gdiplus\GdipDeleteGraphics", "uptr", pGraphics)
		}
		
		GraphicsFromHDC(hdc)
		{
			DllCall("gdiplus\GdipCreateFromHDC", "uptr", hdc, "uptr*", pGraphics)
			return pGraphics
		}
		
		BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, raster="")
		{
			return DllCall("gdi32\BitBlt", "uptr", dDC, "int", dx, "int", dy, "int", dw, "int", dh, "uptr", sDC, "int", sx, "int", sy, "uint", raster ? raster : 0x00CC0020)
		}

		SetSmoothingMode(pGraphics, smoothingMode)
		{
			return DllCall("gdiplus\GdipSetSmoothingMode", "uptr", pGraphics, "int", smoothingMode)
		}
		
		;brush, point, size
		;pGraphics, brush, x, y, w, h
		FillRectangle(params*)
		{
			c := params.MaxIndex()
			if (c = 3)
			{
				;MsgBox, % this.pGraphics, params[1].Pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height
				E := this._FillRectangle(this.pGraphics, params[1].Pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height)
			}
			else if (c = 6)
			{
				E := this._FillRectangle(params[1], params[2], params[3], params[4], params[5], params[6])
			}
			else
				throw "Incorrect number of parameters for Object.FillRectangle()"
			return E
		}
		
		_FillRectangle(pGraphics, pBrush, x, y, w, h)
		{
			return DllCall("gdiplus\GdipFillRectangle", "uptr", pGraphics, "uptr", pBrush, "float", x, "float", y, "float", w, "float", h)
		}
		
		;brush, point, size
		;pGraphics, brush, x, y, w, h
		FillEllipse(params*)
		{
			c := params.MaxIndex()
			if (c = 3)
			{
				E := this._FillEllipse(this.pGraphics, params[1].Pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height)
			}
			else if (c = 6)
			{
				E := this._FillEllipse(params[1], params[2], params[3], params[4], params[5], params[6])
			}
			else
				throw "Incorrect number of parameters for Object.FillEllipse()"
			return E
		}

		_FillEllipse(pGraphics, pBrush, x, y, w, h)
		{
			return DllCall("gdiplus\GdipFillEllipse", "uptr", pGraphics, "uptr", pBrush, "float", x, "float", y, "float", w, "float", h)
		}
		
		;1
		;bitmap
		
		;2
		;bitmap,point
		;pGraphics,bitmap
		
		;3
		;bitmap,point,size
		;pGraphics,bitmap,point
		
		;4
		;pGraphics,bitmap,point, size
		
		;5
		;bitmap,point,size,point,size
		DrawImage(params*)
		{
			c := params.MaxIndex()
			;Tooltip, % c
			;bitmap
			if (c = 1)
			{
				bitmap := params[1]
				E := this._DrawImage(this.pGraphics, bitmap.Pointer, 0, 0, bitmap.Width, bitmap.Height, 0, 0, bitmap.Width, bitmap.Height, bitmap.ImageAttr)
			}
			else if (c = 2)
			{
				if (params[1].__Class = "Gdip.Bitmap")
				{
					bitmap := params[1]
					E := this._DrawImage(this.pGraphics, bitmap.Pointer, params[2].X, params[2].Y, bitmap.Width, bitmap.Height, 0, 0, bitmap.Width, bitmap.Height, bitmap.ImageAttr)
				}
				else
				{
					bitmap := params[2]
					E := this._DrawImage(params[1], bitmap.Pointer, params[2].X, params[2].Y, bitmap.Width, bitmap.Height, 0, 0, bitmap.Width, bitmap.Height, bitmap.ImageAttr)
				}
			}
			else if (c = 3)
			{
				if (params[1].__Class = "Gdip.Bitmap")
				{
					bitmap := params[1]
					;MsgBox, % bitmap.ImageAttributes
					;imageAttr := this.SetImageAttributesColorMatrix([[-1,0,0,0,0],[0,-1,0,0,0],[0,0,-1,0,0],[0,0,0,1,0],[1,1,1,0,1]])
					;MsgBox, % bitmap.ImageAttributes
					E := this._DrawImage(this.pGraphics, bitmap.Pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height, 0, 0, bitmap.Width, bitmap.Height, bitmap.ImageAttr)
					;this.DisposeImageAttributes(imageAttr)
				}
				else
				{
					bitmap := params[2]
					E := this._DrawImage(params[1], bitmap.Pointer, params[3].X, params[3].Y, bitmap.Width, bitmap.Height, 0, 0, bitmap.Width, bitmap.Height, bitmap.ImageAttr)
				}
			}
			else if (c = 4)
			{
				bitmap := params[2]
				E := this._DrawImage(params[1], bitmap.Pointer, params[3].X, params[3].Y, params[4].Width, params[4].Height, 0, 0, bitmap.Width, bitmap.Height, bitmap.ImageAttr)
			}
			else if (c = 5)
			{
				bitmap := params[1]
				E := this._DrawImage(this.pGraphics, bitmap.Pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height, params[4].X, params[4].Y, params[5].Width, params[5].Height, bitmap.ImageAttr)
			}
			else
				throw "Incorrect number of parameters for Object.DrawImage()"
			return E
		}
		
		_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, imageAttr=0)
		{
			;MsGBox, % imageAttr
			E := DllCall("gdiplus\GdipDrawImageRectRect", "uptr", pGraphics, "uptr", pBitmap
						, "float", dx, "float", dy, "float", dw, "float", dh
						, "float", sx, "float", sy, "float", sw, "float", sh
						, "int", 2, "uptr", imageAttr, "uptr", 0, "uptr", 0)
			return E
		}
				
		SetImageAttributesColorMatrix(matrix)
		{
			VarSetCapacity(colorMatrix, 100, 0)
			loop 5
			{
				i := A_Index
				loop 5
				{
					;MsGbox, % matrix[i, A_Index]
					NumPut(matrix[i, A_Index], colorMatrix, ((i - 1) * 20) + ((A_Index - 1) * 4), "float")
				}
			}
			
			DllCall("gdiplus\GdipCreateImageAttributes", "uptr*", imageAttr)
			DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "uptr", imageAttr, "int", 1, "int", 1, "uptr", &colorMatrix, "uptr", 0, "int", 0)
			return imageAttr
		}
		
		DisposeImageAttributes(imageAttr)
		{
			;MsgBox, here 99
			return DllCall("gdiplus\GdipDisposeImageAttributes", "uptr", imageAttr)
		}
		
		DrawShape(shape)
		{
			if (shape.Shape = "Rectangle")
			{
				;MsgBox, % shape.Brush "`n" shape.Point.X "`n" shape.Size.W "`n" shape.Radius
				if (shape.Radius = 0)
					E := this.FillRectangle(shape.Brush, shape.Point, shape.Size)
				else
					E := this.FillRoundedRectangle(shape.Brush, shape.Point, shape.Size, shape.Radius)
			}
			else if (shape.Shape = "Image")
			{
				;MsgBox, % this.Shapes.MaxIndex()
				
				/*
				for k, v in params
				{
					if (v.__Class = "Gdip.Point")
					{
						shape.Point := v
						shape.X := v.X
						shape.Y := v.Y
						params.Remove(k)
					}
				}

				params.Insert(1, shape.Bitmap)
				params.Insert(2, shape.Point)
				*/
				
				;params2 := { 1: shape.Bitmap }
				;params2.Point := 
				
				;bitmap,point,size,point,size,matrix
				;MsgBox, % shape.Bitmap.ImageAttributes
				E := this.DrawImage(shape.Bitmap, shape.Point, shape.AnimateSize)
			}
			else
				throw "Unrecognized shape in Object.DrawShape - " shape.Shape
			this.Shapes.Insert(shape)
			return E
		}
		
		;brush, point, size, r
		;pGraphics, brush, x, y, w, h, r
		FillRoundedRectangle(params*)
		{
			c := params.MaxIndex()
			if (c = 4)
			{
				E := this._FillRoundedRectangle(this.pGraphics, params[1].Pointer, params[2].X, params[2].Y, params[3].Width, params[3].Height, params[4])
			}
			else if (c = 7)
			{
				E := this._FillRoundedRectangle(params[1], params[2].Pointer, params[3], params[4], params[5], params[6], params[7])
			}
			else
				throw "Incorrect number of parameters for Object.FillRoundedRectangle()"
			return E
		}
		
		_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
		{
			r := (w <= h) ? (r < w // 2) ? r : w // 2 : (r < h // 2) ? r : h // 2
			path1 := this.CreatePath(0)
			this.AddPathRectangle(path1, x+r, y, w-(2*r), r)
			this.AddPathRectangle(path1, x+r, y+h-r, w-(2*r), r)
			this.AddPathRectangle(path1, x, y+r, r, h-(2*r))
			this.AddPathRectangle(path1, x+w-r, y+r, r, h-(2*r))
			this.AddPathRectangle(path1, x+r, y+r, w-(2*r), h-(2*r))
			this.AddPathPie(path1, x, y, 2*r, 2*r, 180, 90)
			this.AddPathPie(path1, x+w-(2*r), y, 2*r, 2*r, 270, 90)
			this.AddPathPie(path1, x, y+h-(2*r), 2*r, 2*r, 90, 90)
			this.AddPathPie(path1, x+w-(2*r), y+h-(2*r), 2*r, 2*r, 0, 90)
			this.FillPath(pGraphics, pBrush, path1)
			this.DeletePath(path1)
			return r
		}
		
		SetClipRegion(region, combineMode=0)
		{
			return this._SetClipRegion(this.pGraphics, region, combineMode)
		}
		
		_SetClipRegion(pGraphics, region, combineMode=0)
		{
			return DllCall("gdiplus\GdipSetClipRegion", "uptr", pGraphics, "uptr", region, "int", combineMode)
		}
		
		SetClipRect(x, y, w, h, combineMode=0)
		{
			return this._SetClipRect(this.pGraphics, x, y, w, h, combineMode)
		}
		
		; Replace = 0
		; Intersect = 1
		; Union = 2
		; Xor = 3
		; Exclude = 4
		; Complement = 5
		_SetClipRect(pGraphics, x, y, w, h, combineMode=0)
		{
		   return DllCall("gdiplus\GdipSetClipRect", "uptr", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", combineMode)
		}
		
		GetClipRegion()
		{
			return this._GetClipRegion(this.pGraphics)
		}

		/*
		CreateRoundRectRgn(point1, point2, radius)
		{
			return DllCall("CreateRoundRectRgn", "int", point1.X, "int", point1.Y, "int", point2.X, "int", point2.Y, "int", r, "int", r)
		}
		*/
		
		_GetClipRegion(pGraphics)
		{
			region := this.CreateRegion()
			DllCall("gdiplus\GdipGetClip", "uptr", pGraphics, "uint*", region)
			return region
		}
		
		FillRegion(pGraphics, pBrush, region)
		{
			return DllCall("gdiplus\GdipFillRegion", "uptr", pGraphics, "uptr", pBrush, "uptr", region)
		}
		
		FillPath(pGraphics, pBrush, path)
		{
			return DllCall("gdiplus\GdipFillPath", "uptr", pGraphics, "uptr", pBrush, "uptr", path)
		}
		
		; Alternate = 0
		; Winding = 1
		CreatePath(brushMode=0)
		{
			DllCall("gdiplus\GdipCreatePath", "int", brushMode, "uptr*", path1)
			return path1
		}
		
		DeletePath(path)
		{
			return DllCall("gdiplus\GdipDeletePath", "uptr", path)
		}
		
		AddPathRectangle(path, x, y, w, h)
		{
			return DllCall("gdiplus\GdipAddPathRectangle", "uptr", path, "float", x, "float", y, "float", w, "float", h)
		}
		
		AddPathEllipse(path, x, y, w, h)
		{
			return DllCall("gdiplus\GdipAddPathEllipse", "uptr", path, "float", x, "float", y, "float", w, "float", h)
		}
		
		AddPathArc(path, x, y, w, h, startAngle, sweepAngle)
		{
			return DllCall("gdiplus\GdipAddPathArc", "uptr", path, "float", x, "float", y, "float", w, "float", h, "float", startAngle, "float", sweepAngle)
		}
		
		AddPathPie(path, x, y, w, h, startAngle, sweepAngle)
		{
			return DllCall("gdiplus\GdipAddPathPie", "uptr", path, "float", x, "float", y, "float", w, "float", h, "float", startAngle, "float", sweepAngle)
		}
		
;GpStatus WINGDIPAPI GdipAddPathPie(GpPath *path, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle)		
		
;GpStatus WINGDIPAPI GdipAddPathArc(GpPath *path, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle)
		
		CreateRegion()
		{
			DllCall("gdiplus\GdipCreateRegion", "uint*", region)
			return region
		}
		
		DeleteRegion(region)
		{
			return DllCall("gdiplus\GdipDeleteRegion", "uptr", region)
		}
		
		Clear()
		{
			this.Shapes := []
			return this._GraphicsClear(this.pGraphics)
		}
		
		_GraphicsClear(pGraphics, ARGB=0x00ffffff)
		{
			return DllCall("gdiplus\GdipGraphicsClear", "uptr", pGraphics, "int", ARGB)
		}
	}
	
	class Timer 
	{
		SetTimer(function, period=0, paramObject=0, priority=0) 
		{ 
			Static tmrs := []

			If IsFunc(function)
			{
				if IsObject(tmr := tmrs[this])
				{
					ret := DllCall( "KillTimer", "uptr", 0, "uptr", tmr.tmr)
					;tmr.Running := false
					E := DllCall("GlobalFree", "UInt", tmr.CBA)
					ObjRemove(tmrs, this)
					if (period = 0 || period = "off")
						return ret
				}
				;if (period = 20)
				;	MsGbox, % function.Name "`n" IsObject(paramObject)
				
				tmr := tmrs[this] := { "func": function, "ref": this, "period": (period = "on") ? 250 : period, "Priority": priority
				, "OneTime": (period < 0), "params": IsObject(paramObject) ? paramObject: [], "Tick": A_TickCount }
				tmr.CBA := RegisterCallback(A_ThisFunc, "F", 4, &tmr)
				return !!(tmr.tmr := DllCall("SetTimer", "UInt",0, "UInt",0, "UInt", (period && period != "On") ? Abs(period) : (period := 250), "UInt", tmr.CBA))
			}
			
			if IsObject(tmr := Object(A_EventInfo))
			{
				DllCall("KillTimer", "UInt",0, "UInt", tmr.tmr)
				tmr.tick := ErrorLevel := A_TickCount
				func := tmr.func
				%func%(tmr.ref,tmr.params)
				
				if (tmr.OneTime)
				{
					E := DllCall("GlobalFree", "UInt", tmr.CBA)
					ObjRemove(tmrs, tmr.ref ? tmr.ref: tmr.func)
					return E
				}
				tmr.tmr := DllCall("SetTimer", "UInt",0, "UInt",0, "UInt",((A_TickCount-tmr.Tick) > tmr.period) ? 0 : (tmr.period - (A_TickCount - tmr.Tick)), "UInt", tmr.CBA)
			}
		}
	}
}