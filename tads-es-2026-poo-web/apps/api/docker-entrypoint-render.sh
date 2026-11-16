
#!/bin/sh
set -e

php artisan config:cache

php artisan migrate --force

exec apache2-foreground
