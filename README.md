# backup-script

```
apt install rclone -y
rclone config file
```


```
[cloudflare]
type = s3
provider = Cloudflare
access_key_id = 
secret_access_key = 
endpoint = https://[ACCOUNT_ID].eu.r2.cloudflarestorage.com
acl = private
no_check_bucket = true
```

```
rclone tree cloudflare:
```



