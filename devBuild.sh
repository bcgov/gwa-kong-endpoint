sed 's/VERSION/0.0.0-0/' gwa-kong-endpoint-VERSION.rockspec > gwa-kong-endpoint-0.0.0-0.rockspec
luarocks make gwa-kong-endpoint-0.0.0-0.rockspec
rm gwa-kong-endpoint-0.0.0-0.rockspec

