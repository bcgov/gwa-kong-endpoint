# kong-bcgov-gwa-endpoint

Kong Plugin to process BC Government siteminder headers to apply kong consumers and acls (groups)
to BC Government users.

## Releasing

Follow these instructions to create a new release for a version (e.g. 1.2.1).

```bash
VERSION=1.2.1

# Clone the source code (always checkout a clean copy)
git clone https://gogs.data.gov.bc.ca/DataBC/kong-bcgov-gwa-endpoint
cd kong-bcgov-gwa-endpoint

# Create a new branch
git checkout -b $VERSION-branch

# Rename the rockspec file to the new version (if required).
mv bcgov-gwa-endpoint-*-0.rockspec bcgov-gwa-endpoint-${VERSION}-0.rockspec

# Edit the rockspec file for the new version
vi bcgov-gwa-endpoint-${VERSION}-0.rockspec
```

```
  version = "1.2.1-0"
  tag = "1.2.1"
```

```bash
# Commit the changes and tag version
git commit -a -m "Version $VERSION"
git tag $VERSION
git push origin $VERSION

# Delete the checked out repository
cd ..
rm -rf kong-bcgov-gwa-endpoint
```

## Installing

Follow these instructions to deploy the plugin to each Kong server in the cluster.

### Install the luarocks file

```bash
VERSION=1.2.1

# Clone the source code (always checkout a clean copy)
git clone https://gogs.data.gov.bc.ca/DataBC/kong-bcgov-gwa-endpoint
cd kong-bcgov-gwa-endpoint

# Checkout the version to a branch
git checkout tags/$VERSION -b $VERSION-branch

# Make the lua rock file and deploy to the shared lua repository
luarocks make

# Delete the checked out repository
cd ..
rm -rf kong-bcgov-gwa-endpoint
```

### Add the plugin to the kong configuration

Edit the kong.conf file 

```
custom_plugins = otherplugin,bcgov-gwa-endpoint
```
