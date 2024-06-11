# slackmojicurl
- A utility script to call Slack APIs using the same auth cookie and API token that are used to load the custom emoji page.

# Setup
- Clone the repository
- Copy [example.env](example.env) as `.env`
- Update values in `.env` as follows
  - From Slack, click on the bottom arrow near the workspace name in the left top corner. Go to Tools -> Customize workspace. This opens `https://<your-workspace>.slack.com/customize/emoji`
  - `WORKSPACE_URL`: Extract the domain of the above URL- `https://<your-workspace>.slack.com`
  - `API_TOKEN`: From Developer tools, go to Console and run `boot_data.api_token` and copy the value 
  - `AUTH_COOKIE`: From Developer tools, go to Application -> Storage -> Cookies -> <domain> and copy the `d` cookie value

# slackmojicurl usage
- `slackmojicurl <emoji endpoint> [<form param1> form param2> ...]`
- `$SUCCESS : boolean` and `$RESPONSE : JSON` will be [set by the script](https://github.com/sspathare97/slackmojicurl/blob/main/slackmojicurl.sh#L71)

# Backup all emojis in the workspace
- Run [scripts/backup.sh](scripts/backup.sh)

# Running and extending scripts
- Run the scripts under [scripts](scripts)
- Add your own scripts as needed. [scripts/upload.sh](scripts/upload.sh) is a good example to get started
