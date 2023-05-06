# Ideas, Thoughts, and Future Plans

## Misc
- Script playlist additions to keep uploaded but unreleased vids out of the playlist
- 2nd channel to try out things like API access?
- pop filter?
- Cleanup OBS files about once a week? Once a month?

## makeThumbnail.ps1
- Need a way to create a thumbnail w/out episode (one-offs, interruptions, etc)
- store api keys / env vars (Azure Key Vault? Session vars?) and use the YouTube API to automate uploads, set scheduling
- Keep track of the last episode number (per seriesName)
- - Simple text file w/ key/value pairs would probably do this. Maybe JSON (see next bullet. convertto/from-json)?
- - Extend this to other things like description, thumbnail background, contact block, etc? Yes. Allow for cli overrides.

## OBS

## Resolve
- Backup strategies? Probably not going to use this tool much, but a cursory glance at options is probably a good idea.

# Completed
- ~~Better mic
- ~~ Description created from standard bits and pieces (sorta like mail merge for video descriptions)
- ~~Get a better handle on scenes, ex. fade to 10-20s of outro for YT end screen. Should be short. Enough time to say thanks for watching. Hate lengthy outros.
- - ~~Added end screen in OBS w/ hotkey to transition. YT limits end screen to 20s (good).