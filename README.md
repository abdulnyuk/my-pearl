# my-pearl

Slim Docker image untuk Pearl mining (alpha-miner v1.6.0) di SaladCloud.

## Image
`ghcr.io/<username>/my-pearl:latest`

## Salad env vars
- `WALLET` (required) — alamat Pearl, format `prl1...`
- `POOL_URL` (default `eu1.alphapool.tech:5566`)
- `POOL_PASSWORD` (default `x;d=131072`)
- `WORKER_PREFIX` (default `salad`)
