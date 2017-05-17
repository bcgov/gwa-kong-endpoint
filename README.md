# kong-bcgov-gwa-endpoint

Kong Plugin to process BC Government siteminder headers to 

## Releasing

Follow these instructions to create a new release for a version (e.g. 1.0.0).

1. Checkout the source code (always checkout a clean copy)
```bash
git clone https://gogs.data.gov.bc.ca/DataBC/kong-bcgov-gwa-endpoint
cd kong-bcgov-gwa-endpoint
```
2. Create a new branch
```bash
git checkout -b 1.0.0-branch
```
2. Rename the rockspec file to the new version (if required).
  For example if the new version is 1.0.0
  bcgov-gwa-endpoint-1.0.0-0.rockspec
3. Edit the rockspec file for the new version
  version = "1.0.0-0"
  tag = "1.0.0"
4. Commit the changes and tag version
```bash
git commit -a -m "Version 1.0.0"
git tag 1.0.0
git push origin 1.0.0
```
5. Delete the temporary repository
```bash
cd ..
rm -r kong-bcgov-gwa-endpoint
```


