

tg = selected ("TextGrid")
snd = selected ("Sound")
sndName$ = selected$ ("Sound")

include tools/importFunctions.praat
@getSettings

beginPause: "Set Parameters"
    comment: "Files will be saved directly into the folder specified here."
    sentence: "Folder:", folder$
    positive: "Segment tier:", 1
		positive: "Word tier:", 2
		sentence: "Marker", "_x"
    boolean: "Save information:", 1
    boolean: "Return table:", 0
endPause: "Ok", 1

selectObject: tg
nIntervals = Get number of intervals: segment_tier

tbl = Create Table with column names: "table", 0, "file filename vowel interval start end word word_interval word_start word_end previous_sound next_sound previous_word next_word"

count = 0
for i from 1 to nIntervals
  selectObject: tg
  vowel$ = Get label of interval: segment_tier, i
  analyze_marker$ = right$ (vowel$,2)

  if analyze_marker$ = marker$

    next_sound$ = "--"
    previous_sound$ = "--"
    if i > 1
      previous_sound$ = Get label of interval: segment_tier, i-1
      if previous_sound$ == ""
        previous_sound$ = "-"
      endif
    endif
    if i < nIntervals
      next_sound$ = Get label of interval: segment_tier, i+1
      if next_sound$ == ""
        next_sound$ = "-"
      endif
    endif

    vowel$ = vowel$ - "_x"

    vowelStart = Get start time of interval: segment_tier, i
    vowelEnd = Get end time of interval: segment_tier, i

    wordNum = Get interval at time: word_tier, (vowelStart+vowelEnd)/2
    word$ = Get label of interval: word_tier, wordNum
    wordStart = Get start time of interval: word_tier, wordNum
    wordEnd = Get end time of interval: word_tier, wordNum

    next_word$ = "-"
    previous_word$ = "-"
    if wordNum > 1
      previous_word$ = Get label of interval: word_tier, wordNum-1
      if previous_word$ == ""
        previous_word$ = "-"
      endif
    endif
    maxwords = Get number of intervals: word_tier
    if wordNum < maxwords
      next_word$ = Get label of interval: word_tier, wordNum+1
      if next_word$ == ""
        next_word$ = "-"
      endif
    endif

    count = count + 1
    selectObject: snd
    snd_small = Extract part: vowelStart - 0.025, vowelEnd + 0.025, "rectangular", 1, "no"
    if count > 999
      filename$ = sndName$ + "_" + string$(count)
    endif
    if count > 99 count < 1000
      filename$ = sndName$ + "_0" + string$(count)
    endif
    if count > 9 & count < 100
      filename$ = sndName$ + "_00" + string$(count)
    endif
    if count < 10
      filename$ = sndName$ + "_000" + string$(count)
    endif
    Save as WAV file: folder$ + "/" + filename$ + ".wav"

    removeObject: snd_small

    selectObject: tbl
    Append row
    Set numeric value: count, "file", count
    Set string value: count, "filename", filename$
    Set numeric value: count, "start", vowelStart
    Set numeric value: count, "end", vowelEnd
    Set string value: count, "vowel", vowel$
    Set string value: count, "word", word$
    Set numeric value: count, "word_interval", wordNum
    Set numeric value: count, "word_start", wordStart
    Set numeric value: count, "word_end", wordEnd
    Set numeric value: count, "interval", i
    Set string value: count, "previous_sound", previous_sound$
    Set string value: count, "next_sound", next_sound$
    Set string value: count, "previous_word", previous_word$
    Set string value: count, "next_word", next_word$
  endif
endfor
selectObject: tbl
if save_information = 1
  Save as comma-separated file: folder$ + "/"+ sndName$+ "_segmentation_info.csv"
endif

if return_table == 0
  removeObject: tbl
endif