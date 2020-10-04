# Tender

Steem Engine sidechain interpreter.

### What It Is

For the most part, Tender is simply a Steem Engine block explorer.  But it's a little more than just that.  It's also a rest endpoint for querying account history.  For example, if you're running an exchange, you can use your own tender node to programmatically query deposits to your exchange.

Running your own node means you won't have to rely on `api.hive-engine.com` to query current sidechain activity.

To set it up:

```bash
docker run -it --name tender -p 5000:5000 -p 3000:3000 inertia/tender:latest
```

The above `docker` command will initialize an internal Steem Engine node on port 5000, replay the latest block log, and start the explorer on port 3000.

Once set up, you can browse the sidechain here:

http://localhost:3000/

For exchanges, perhaps the most useful URL is, for example the last 100 transfers to the account named alice:

http://localhost:3000/transfers/alice.json

Or, get the last 1000 to alice:

http://localhost:3000/transfers/alice/1000.json

This is how you query the second 1000 transfers of `ENG` tokens to alice:

http://localhost:3000/transfers/alice/ENG/1000/2.json

### More Details

If you already have your own `steemd` node running `block_api`, you can point to that node for new blocks.

```bash
docker run --env STEEMD_NODE_URL=http://your-steemd-node-here:8090 \
  -it --name tender \
  -p 5000:5000 \
  -p 3000:3000 \
  inertia/tender:latest
```

Also see: https://hub.docker.com/r/inertia/tender/

---

<center>
  <img src="https://i.imgur.com/TZKDRue.png" />
</center>

See some of my previous Ruby How To posts in: [#radiator](https://steemit.com/created/radiator) [#ruby](https://steemit.com/created/ruby)

## Get in touch!

If you're using Tender, I'd love to hear from you.  Drop me a line and tell me what you think!  I'm @inertia on STEEM.
  
## License

I don't believe in intellectual "property".  If you do, consider Radiator as licensed under a Creative Commons [![CC0](http://i.creativecommons.org/p/zero/1.0/80x15.png)](http://creativecommons.org/publicdomain/zero/1.0/) License.
