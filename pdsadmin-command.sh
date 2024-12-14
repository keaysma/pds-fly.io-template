# pdsadmin is a tool for managing the Personal Data Store (PDS) server.
# But at the end of the day, it's just a bash script that makes curl requests
# Even worse, it does all sorts of annoying checks that don't apply to OSX
# So I have reversed engineered the requests I cared about and put them here

# You can copy and paste these into your terminal,
# Remove the underscores before the curl command
# Replace the variables with your own values

export PDS_HOST="PDS_HOST"
export PDS_ADMIN_PASSWORD="PDS_ADMIN_PASSWORD"
export DID="DID"

# make an invite code
_curl \
    --fail \
    --silent \
    --show-error \
    --request POST \
    --header "Content-Type: application/json" \
    --user "admin:${PDS_ADMIN_PASSWORD}" \
    --data '{"useCount": 1}' \
    "https://${PDS_HOST}/xrpc/com.atproto.server.createInviteCode"

# make account directly
_curl \
    --silent \
    --show-error \
    --request POST \
    --header "Content-Type: application/json" \
    --data "{\"email\":\"your@email.com\", \"handle\":\"hanlde.${PDS_HOST}\", \"password\":\"aP@SSW0rD!\", \"inviteCode\":\"your-invite-code-from-above\"}" \
    "https://${PDS_HOST}/xrpc/com.atproto.server.createAccount"

# lets start over
_curl \
    --fail \
    --silent \
    --show-error \
    --request POST \
    --header "Content-Type: application/json" \
    --user "admin:${PDS_ADMIN_PASSWORD}" \
    --data "{\"did\": \"${DID}\"}" \
    "https://${PDS_HOST}/xrpc/com.atproto.admin.deleteAccount"
