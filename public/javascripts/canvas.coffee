$ ->
  # File API対応済みブラウザかをチェック
  if !window.File || !window.FileReader
    alert 'ブラウザが対応していません'
    return

  $('#upload_file').change ->
    # 選択ファイルの有無をチェック
    if !@files.length
      alert 'ファイルが選択されていません'
      return
    # Formからファイルを取得
    file = @files[0]
    # (1) HTMLのCanvas要素の取得
    canvas = $('#canvas')
    # (2) getContext()メソッドで描画機能を有効にする
    ctx = canvas[0].getContext('2d')
    # 描画イメージインスタンス化
    image = new Image
    # File API FileReader Objectでローカルファイルにアクセス
    fr = new FileReader
    # ファイル読み込み読み込み完了後に実行 [非同期処理]
    fr.onload = (evt) ->
      # 画像がロードされた後にcanvasに描画を行う [非同期処理]
      image.onload = ->
        # (3) プレビュー(canvas)のサイズを指定
        cnvsH = 400
        cnvsW = image.naturalWidth * cnvsH / image.naturalHeight
        # (4) canvasにサイズアトリビュートを設定する
        canvas.attr 'width', cnvsW
        canvas.attr 'height', cnvsH
        # (5) 描画
        ctx.drawImage image, 0, 0, cnvsW, cnvsH
        return
      # 読み込んだ画像をimageのソースに設定
      image.src = evt.target.result
      return
    # fileを読み込むデータはBase64エンコードされる
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

  $('#drop_zone').on 'drop', (e) ->
    e.preventDefault()
    file = e.originalEvent.dataTransfer.files[0]
    if file.type != 'image/jpeg' || file.type != 'image/png'
      alert '拡張子jpg、png以外は対応していません'
      return
    canvas = $('#canvas')
    ctx = canvas[0].getContext('2d')
    image = new Image
    fr = new FileReader
    fr.onload = (evt) ->
      image.onload = ->
        cnvsH = 400
        cnvsW = image.naturalWidth * cnvsH / image.naturalHeight
        canvas.attr 'width', cnvsW
        canvas.attr 'height', cnvsH
        ctx.drawImage image, 0, 0, cnvsW, cnvsH
        return
      image.src = evt.target.result
      return
    fr.readAsDataURL file
  return