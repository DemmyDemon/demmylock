# Code files

Any files in this directory with a name that ends in .lua will automatically be loaded on the server.

That makes this a great place to put your `AddCodes()` files!

For example, if you want to define the `Playboy Perimeter` codes, you make a file called `playboy.lua` and put this in it:

```lua
AddCodes('Playboy Perimeter', {
    _default = '1234',
    ['Gate C'] = '4321',
})
```

Now all the doors in the `Playboy Perimeter` area will have the code `1234`, except `Gate C`, which will have the code `4321`.

# Wait what? Strings?

Yes, the codes are strings. This is for uniformity when you suddenly have a code with `*` or `#` in it, or leading zeroes.

# Match your locks!

Make absolutely sure that the area name (`Playboy Perimeter` in this example) and any non-default lock names (`Gate C` in this example) matches the [lock file](../locks/place_lock_files_here.md) you set up **exactly**. It's even CaSe SeNsItIvE!