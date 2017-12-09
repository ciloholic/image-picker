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
    canvas = $('#left_canvas')
    ctx = canvas[0].getContext('2d')
    image = new Image
    fr = new FileReader
    # ファイル読み込み後に実行 [非同期]
    fr.onload = (e) ->
      # 画像ロード後に実行 [非同期]
      image.onload = ->
        canvasW = 400
        canvasH = Math.floor(canvasW * image.naturalHeight / image.naturalWidth)
        canvas.attr 'width', canvasW
        canvas.attr 'height', canvasH
        # canvasへ描画
        ctx.drawImage image, 0, 0, canvasW, canvasH
        # 減色処理
        reducedColor(16)
        # オートセレクト
        autoSelect()
        return
      image.src = e.target.result
      return
    fr.readAsDataURL @files[0]
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
    canvas = $('#left_canvas')
    ctx = canvas[0].getContext('2d')
    image = new Image
    fr = new FileReader
    # ファイル読み込み後に実行 [非同期]
    fr.onload = (e) ->
      # 画像ロード後に実行 [非同期]
      image.onload = ->
        canvasW = 400
        canvasH = Math.floor(canvasW * image.naturalHeight / image.naturalWidth)
        canvas.attr 'width', canvasW
        canvas.attr 'height', canvasH
        # canvasへ描画
        ctx.drawImage image, 0, 0, canvasW, canvasH
        # 減色処理
        reducedColor(16)
        # オートセレクト
        autoSelect()
        return
      image.src = e.target.result
      return
    fr.readAsDataURL file
    return

  # 減色処理
  reducedColor = (num) ->
    leftCanvas = $('#left_canvas')
    leftCtx = leftCanvas[0].getContext('2d')
    canvasW = leftCanvas.prop 'width'
    canvasH = leftCanvas.prop 'height'
    # ImageDataの生成
    imagedata = leftCtx.getImageData(0, 0, canvasW, canvasH)
    # 画像のカラー情報を取得
    colors = getColorInfo(imagedata)
    # 減色
    medianCut = new TMedianCut(imagedata, colors)
    medianCut.run num, true
    # canvasへ描画
    rightCanvas = $('#right_canvas')
    rightCanvas.attr 'width', canvasW
    rightCanvas.attr 'height', canvasH
    rightCtx = rightCanvas[0].getContext('2d')
    rightCtx.putImageData imagedata, 0, 0
    return

  # スポイト
  $('#right_canvas').on click: (e) ->
    canvas = $('#right_canvas')
    rightCtx = canvas[0].getContext('2d')
    rect = canvas[0].getBoundingClientRect()
    mouseX = Math.round(e.clientX - rect.left)
    mouseY = Math.round(e.clientY - rect.top - ((400 - canvas[0].height) / 2))
    imagedata = rightCtx.getImageData(0, 0, canvas[0].width, canvas[0].height)
    i = ((mouseY * canvas[0].width) + mouseX) * 4
    rgb =
      r: imagedata.data[i]
      g: imagedata.data[i + 1]
      b: imagedata.data[i + 2]
    console.log convertHex(rgb) + ' => %ccolor', 'background-color: ' + convertHex(rgb)
    return

  # オートセレクト
  autoSelect = ->
    canvas = $('#right_canvas')
    rightCtx = canvas[0].getContext('2d')
    imagedata = rightCtx.getImageData(0, 0, canvas[0].width, canvas[0].height)
    hex = []
    max = imagedata.data.length / 4
    i = 0
    while i < max
      rgb =
        r: imagedata.data[i]
        g: imagedata.data[i + 1]
        b: imagedata.data[i + 2]
      hex.push(convertHex(rgb))
      i += 4
    # 色の重複を削除
    hexOverlap = hex.filter((v, i, s) -> s.indexOf(v) == i)
    # 色の集計
    sort = []
    for key, value of hexOverlap
      sort.push({color: value, cnt: hex.filter((v, i) -> v == value).length})
    # 色の並び替え
    sort.sort (a, b) ->
      if a.cnt < b.cnt
        return 1
      if a.cnt > b.cnt
        return -1
      return 0
    # チャート描画
    canvas = $('#chart_canvas')
    canvas.attr('width', 400);
    canvas.attr('height', 400);
    chart_color = sort.slice(0, 10).map((v) -> v.color)
    chart_cnt = sort.slice(0, 10).map((v) -> v.cnt)
    chart_canvas = new Chart(canvas,
      type: 'polarArea'
      data:
        labels: chart_color
        datasets: [{
          data: chart_cnt
          backgroundColor: chart_color
          borderColor: chart_color
          borderWidth: 1
        }]
      options: responsive: false
    )
    return

  # RGB(255,255,255) -> HEX(#ffffff)
  convertHex = (rgb) -> '#' + toHex(rgb.r) + toHex(rgb.g) + toHex(rgb.b)

  # NUMBER(255) -> HEX(ff)
  toHex = (v) -> ('0' + v.toString(16)).substr(-2)

  return
