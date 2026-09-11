# How to verify a Watercraft live installer ISO file

## Step 1. Import Watercraft signing key 

by ID:

```sh
gpg --keyserver keys.openpgp.org --recv-keys 6066E4509E00ED74
```

by `.asc` file
```sh
gpg --import watercraft-public.asc
```

`.asc` file may be the more reliable path.

`watercraft-public.asc` is available included alongside any release or at: [https://phosphene.xyz/gpg-keys/watercraft-public.asc](https://phosphene.xyz/gpg-keys/watercraft-public.asc)


---
## Step 2. Confirm the fingerprint matches the correct one
```
2D77 384D 04C6 968E 1FBF  E957 6066 E450 9E00 ED74
```

 
Same exact fingerprint should be found in README and here. 

After importing in `Step 1.` verify with:

```sh
gpg --fingerprint 2D77384D04C6968E1FBFE9576066E4509E00ED74
```
---
## Step 3. Verify that the signed checksums file contains valid signatures from the Watercraft signing key:

```sh
gpg --verify SHA256SUMS.asc SHA256SUMS
```
You should see `Good signature` in the middle of the output.

---
## Step 4. Verify that the ISO matches it's checksum:

```sh
sha256sum -c SHA256SUMS
```

If that prints `: OK` at the end of it's output, you're good to go.

---
