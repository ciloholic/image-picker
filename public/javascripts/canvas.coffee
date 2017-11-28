$ ->
  # File API対応済みブラウザかをチェック
  if !window.File || !window.FileReader
    alert 'ブラウザが対応していません'
    return

  # ファイル選択処理
  $('#upload_file').change ->
    # 選択ファイルの有無をチェック
    if !@files.length
      alert 'ファイルが選択されていません'
      return
    file = @files[0]
    leftCanvas = $('#left_canvas')
    ctx = leftCanvas[0].getContext('2d')
    image = new Image
    fr = new FileReader
    # ファイル読み込み後に実行 [非同期]
    fr.onload = (e) ->
      # 画像ロード後に実行 [非同期]
      image.onload = ->
        canvasH = 400
        canvasW = image.naturalWidth * canvasH / image.naturalHeight
        leftCanvas.attr 'width', canvasW
        leftCanvas.attr 'height', canvasH
        # canvasへ描画
        ctx.drawImage image, 0, 0, canvasW, canvasH
        # 減色処理
        reducedColor(256)
        return
      image.src = e.target.result
      return
    fr.readAsDataURL file
    return

  $('#drop_zone').on 'dragenter', (e) ->
    e.preventDefault()
    e.stopPropagation()
    return false

  $('#drop_zone').on 'dragover', (e) ->
    e.preventDefault()
    e.stopPropagation()
    return false

  # ファイルドロップ処理
  $('#drop_zone').on 'drop', (e) ->
    e.preventDefault()
    file = e.originalEvent.dataTransfer.files[0]
    if file.type != 'image/jpeg' && file.type != 'image/png'
      alert '拡張子jpg、png以外は対応していません'
      return
    leftCanvas = $('#left_canvas')
    ctx = leftCanvas[0].getContext('2d')
    image = new Image
    fr = new FileReader
    fr.onload = (e) ->
      image.onload = ->
        canvasH = 400
        canvasW = image.naturalWidth * canvasH / image.naturalHeight
        leftCanvas.attr 'width', canvasW
        leftCanvas.attr 'height', canvasH
        ctx.drawImage image, 0, 0, canvasW, canvasH
        # 減色処理
        reducedColor(256)
        return
      image.src = e.target.result
      return
    fr.readAsDataURL file
    return

  # 減色処理
  reducedColor = (num) ->
    leftCanvas = $('#left_canvas')
    leftCtx = leftCanvas[0].getContext('2d')
    # ImageDataの生成
    canvasW = leftCanvas.prop 'width'
    canvasH = leftCanvas.prop 'height'
    imagedata = leftCtx.getImageData(0, 0, canvasW, canvasH)
    # 画像のカラー情報を取得
    colors = getColorInfo(imagedata)
    # 減色処理
    medianCut = new TMedianCut(imagedata, colors)
    medianCut.run num, true
    # canvasへ描画
    rightCanvas = $('#right_canvas')
    rightCanvas.attr 'width', canvasW
    rightCanvas.attr 'height', canvasH
    rightCtx = rightCanvas[0].getContext('2d')
    rightCtx.putImageData imagedata, 0, 0
    return

  #$('#left_canvas').on click: (e) ->
    canvas = $('#left_canvas')
    ctx = canvas[0].getContext('2d')
    mouseX = parseInt(e.offsetX)
    mouseY = parseInt(e.offsetY)
    imagedata = ctx.getImageData(0, 0, @.width, @.height)
    data = imagedata.data
    i = (mouseY * @.width + mouseX) * 4
    r = data[i]
    g = data[i + 1]
    b = data[i + 2]
    a = data[i + 3]
    convertHex(r: r, g: g, b: b)
    return

  convertHex = (rgb) ->
    rgb.r.toString(16) + rgb.g.toString(16) + rgb.b.toString(16)
  return
