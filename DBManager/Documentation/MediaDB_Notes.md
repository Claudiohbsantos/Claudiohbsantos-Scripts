## Notes
	
MediaDB files can be edited while reaper is running. New entries will be shown upon refresh (default f5)

Search will NOT refresh the database automatically


## Syntax

```
PATH "*pathtodirectory*"
FILE "*filepath*" *file_size_low32* *file_size_hi32* *file_date_seconds_since_1970*
DATA "u:*usertag for file above*" "d:*BWF_Description*"
```

- *file_size_low32* = size in bytes
- *file_size_hi32* = can pretty much always be 0


## Info I want and how to get it

OS
-Filename
-Filesize

MediaInfo
-General
--Album                                    : CD Tile
--Track name                               : Track Title
--Track name/Position                      : 1
--Performer                                : Library
--Composer                                 : Composer
--Producer                                 : Originator
--Publisher                                : Publisher
--Genre                                    : Category
--Description                              : Description
--Encoded date                             :  
--Encoding settings                        : BaseHead Injected
--Comment                                  : Description
-
-Audio
--Format                                   : PCM
--Duration                                 : 1 s 0 ms
--Channel(s)                               : 1 channel
--Sampling rate                            : 48.0 kHz
--Bit depth                                : 24 bits

BWFMetaEdit

BWFXML
-PROJECT
-SCENE
-TAKE
-TAPE
-CIRCLED
-FILE_UID
-SPEED
--NOTE
--MASTER_SPEED
--CURRENT_SPEED
--TIMECODE_FLAG
--TIMECODE_RATE
--FILE_SAMPLE_RATE
--AUDIO_BIT_DEPTH
--DIGITIZER_SAMPLE_RATE
--TIMESTAMP_SAMPLES_SINCE_MIDNIGHT_HI
--TIMESTAMP_SAMPLES_SINCE_MIDNIGHT_LO
--TIMESTAMP_SAMPLE_RATE
-UBITS
-SYNC_POINT_LIST
--SYNC_POINT
---SYNC_POINT_TYPE
---SYNC_POINT_FUNCTION
---SYNC_POINT_COMMENT
---SYNC_POINT_LOW
---SYNC_POINT_HIGH
---SYNC_POINT_EVENT_DURATION
--SYNC_POINT
---SYNC_POINT_TYPE
---SYNC_POINT_FUNCTION
---SYNC_POINT_LOW
---SYNC_POINT_HIGH
---SYNC_POINT_EVENT_DURATION
-NOTE
-HISTORY
--ORIGINAL_FILENAME
--PARENT_FILENAME
--PARENT_UID
-FILE_SET
--TOTAL_FILES
--FAMILY_UID
--FAMILY_NAME
--FILE_SET_INDEX
-TRACK_LIST
--TRACK_COUNT
--TRACK
---CHANNEL_INDEX
---INTERLEAVE_INDEX
---NAME
---FUNCTION
--TRACK
---CHANNEL_INDEX
---INTERLEAVE_INDEX
---NAME
---FUNCTION
-BEXT
--BWF_TIME_REFERENCE_LOW
--BWF_TIME_REFERENCE_HIGH
--BWF_ORIGINATOR
--BWF_ORIGINATOR_REFERENCE
--BWF_DESCRIPTION
--BWF_ORIGINATION_DATE
--BWF_ORIGINATION_TIME
--BWF_VERSION
--BWF_CODING_HISTORY
-USER
Microphones=COS11


