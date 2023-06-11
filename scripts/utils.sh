function download_latest_ghhook {

#currently proken
sudo mkdir -p /opt/gthooks/
sudo apt-get install jq -y
wget $(curl -s https://api.github.com/repos/thecreed/ghhooks/releases/latest |  jq -r '.assets | .[] | select(.name|contains("amd64.zip")) | .browser_download_url')
unzip gthooks*.zip
sudo cp gthooks /opt/gthooks/gthooks
sudo chmod +x /opt/gthooks/gthooks
}

function update_site {
set +e
pushd $(mktemp -d)
sudo apt-get install jq -y
wget $(curl -s https://api.github.com/repos/thecreed/eslutsky.com/releases/latest |  jq -r '.assets | .[] | select(.name|contains("public.tar.gz")) | .browser_download_url')
sudo tar xvfz public.tar.gz -C /var/www/
sudo chown -R wordpress:wordpress /var/www/public
sudo rm -rf /var/www/eslutsky.com && sudo mv /var/www/public /var/www/eslutsky.com
popd
}

function install_githook_service {

cp /opt/gthooks/example.toml /opt/gthooks/eslutsky.toml
#must run as sudo
cat <<__EOF__ | sudo tee /etc/systemd/system/git-hook-listener.service
[Unit]
Description=GitHook Listener
After=network.target

[Service]
ExecStart=/opt/gthooks/gthooks -config /opt/gthooks/eslutsky.toml
ExecReload=
Type=simple
Restart=always


[Install]
WantedBy=default.target
RequiredBy=network.target
__EOF__

sudo systemctl daemon-reload
sudo systemctl start  git-hook-listener.service
sudo systemctl enable  git-hook-listener.service
}

s
/etc/systemd/system/rot13.service