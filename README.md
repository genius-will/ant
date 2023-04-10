### BUILD

```shell
sui move build
```
### This is a gamefi

### TEST

```shell
sui move test
```

### PUBLISH
```shell
sui client publish --gas-budget 100000 --skip-fetch-latest-git-deps
```

### REGISTER

```shell
sui client call --function register --module main --package 0x18fa322fb0d5411b3f1b3fd59fae592fb0902ab4 --args 0xb04ce560392854b139e10917566d0caac15e83e3 --gas-budget 100000

```