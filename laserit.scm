(define (script-fu-laserit image drawable process dpi max_width max_height)
  (gimp-image-undo-group-start image)
  (gimp-context-push)

  (gimp-layer-flatten drawable)
  (let* (
      (width (car (gimp-image-width image)))
      (height (car (gimp-image-height image)))
      (neww (* 25.4 (/ width dpi)))
      (newh (* 25.4 (/ height dpi)))
      (scrap1 (/ max_width neww))
      (scrap2 (/ max_height newh))
      (factor scrap1)
      (if (< scrap1 scrap2) (factor scrap2))
      (fw (* width factor))
      (fh (* height factor))
    )
    ;(gimp-message (number->string fw))

    (gimp-image-set-resolution image dpi dpi)
    (gimp-image-scale image fw fh)
  )

  (if (= process 0) (tile image drawable))
  (if (= process 1) (norton_tile image drawable))
  (if (= process 2) (mirror image drawable))
  (if (= process 3) (wood image drawable))

  (define filename (car(gimp-image-get-filename image)))
  (define parts (strbreakup filename "."))
  (define base (car parts))
  (define ext (cadr parts))

  (gimp-image-set-filename image (string-append base "-laserit." ext))

  (gimp-context-pop)
  (gimp-image-undo-group-end image)
  (gimp-displays-flush)
)

(define (mirror image drawable)
    (gimp-item-transform-flip-simple drawable ORIENTATION-HORIZONTAL TRUE 0)
    (process image drawable 22.5 (list 0 0 0) (list 235 235 235))
)

(define (tile image drawable)
    (gimp-invert drawable)
    (process image drawable 22.5 (list 0 0 0) (list 235 235 235))
)

(define (norton_tile image drawable)
    (process image drawable 22.5 (list 0 0 0) (list 235 235 235))
)

(define (wood image drawable)
    (process image drawable 63 (list 92 92 92) (list 224 224 224))
)

(define (process image drawable angle foreground background)
    (gimp-context-set-foreground foreground)
    (gimp-context-set-background background)
    (if (eqv? (car (gimp-drawable-is-gray drawable)) FALSE)
      (gimp-image-convert-grayscale image)
    )
    (plug-in-unsharp-mask RUN-NONINTERACTIVE image drawable 3.0 2.3 0)
    (plug-in-newsprint RUN-NONINTERACTIVE image drawable 5 0 0 angle 0 0 0 0 0 0 0 2)
)

(script-fu-register
    "script-fu-laserit"
    "LaserIT!"
    "Automatically Process images for laser engraving."
    "Anthony Taylor"
    "copyright 2021, Anthony Taylor"
    "2021"
    "RGB*, GRAY*"
    SF-IMAGE      "Image"           0
    SF-DRAWABLE   "Drawable"        0
    SF-OPTION     "Process"         '("Tile" "Norton Tile" "Mirror" "Wood")
    SF-VALUE      "DPI"		        "600"
    SF-VALUE      "Max Width (mm)"  "100"
    SF-VALUE	  "Max Height (mm)" "100"
)
(script-fu-menu-register "script-fu-laserit" "<Image>/LaserIT!")