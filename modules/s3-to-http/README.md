Listen to upload events in S3 and dispatch them to an HTTP API.

> **Important!** EventBridge must be enabled in the buckets.

Example:

```hcl
module "image_processor" {
  source = "..."

  name = "image-processor"
  url = "https://myapp.example.com/process-image/"
  s3_paths = {
    "avatars" = "s3://user-data/uploads/user-avatar/"
    "article-pictures" = "s3://blog-data/uploads/articles/"
  }
}
```

Each event dispatched will make a `POST` request to the specified endpoint with
a JSON payload similar to the following example:

```json
{
  "bucket": "user-data",
  "key": "uploads/user-avatar/carol.jpg",
  "size": "714832",
  "etag": "5244bc882ebc3994a8645c7da2dc9550"
}
```
