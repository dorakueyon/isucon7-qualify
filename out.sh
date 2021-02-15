filename="$(date '+%Y.%m.%d.%H:%M:%S' ).html"
target_path="./webapp/public/results/${filename}"

echo "<html><body><pre style=\"font-family: 'Courier New', Consolas, monospace;\">" >> "$target_path"
make alp >> "$target_path"
make pt >> "$target_path"

#echo "http://localhost:8080/results/${filename}"  | ./notify_slack -c ./notify_slack.toml
echo "http://localhost:8080/results/${filename}"
