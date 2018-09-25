# gwa-kong-endpoint

Kong Plugin to process BC Government siteminder headers to apply kong consumers and acls (groups)
to BC Government users.

NOTE: This version requires kong >= 0.14.1

## Installing

Follow these instructions to deploy the plugin to each Kong server in the cluster.

### Install the luarocks file

`luarocks install gwa-kong-endpoint`

### Add the plugin to the kong configuration

Edit the kong.conf file 

```
custom_plugins = otherplugin,gwa-kong-endpoint
```

# License

```
Copyright 2018 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
