# backup-script
```
wget -qO /usr/local/bin/backup https://raw.githubusercontent.com/iandk/backup-script/main/backup.sh && chmod +x /usr/local/bin/backup && nano /usr/local/bin/backup
```
```
apt install rclone -y
rclone config file
```
```
crontab -e 
@daily /usr/local/bin/backup

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



