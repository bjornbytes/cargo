Cargo
===

Cargo makes it easy to manage assets in a Love2D project by exposing project directories as Lua tables.
Assets are lazily loaded, cached, and can be nested arbitrarily.

Example
---

If you have a project structured like this:

```
├── main.lua
└── assets
    ├── config
    │   └── player
    │       └── stats.lua
    ├── fonts
    │   └── my_font.ttf
    └── images
        └── player.png
```

Then you can do this:

```lua
assets = require('cargo').init('assets')

function love.load()
  print(assets.config.player.stats.maxHealth)
  myFont = assets.fonts.my_font(16)
end

function love.draw()
  love.graphics.draw(assets.images.player)
end
```

And it will just work.  You can also do the following to expose your entire project as part of the Lua global scope:

```lua
setmetatable(_G, {
  __index = require('cargo').init('/')
})
```

In this example, if you have an image located at `images/player.png`, you can just call `love.graphics.draw(images.player)` without having to call `love.graphics.newImage`.

Advanced
---

There are two ways to tell cargo to load a directory. The first is by passing in the name of the directory you want to load:

```lua
assets = cargo.init('my_assets')
```

The second is by passing in an options table, which gives you more power over how things are loaded:

```lua
assets = cargo.init({
  dir = 'my_assets',
  loaders = {
    jpg = love.graphics.newImage
  },
  processors = {
    ['images/'] = function(image, filename)
      image:setFilter('nearest', 'nearest')
    end
  }
})
```

### Loaders

The `loaders` option specifies how to load assets.
Cargo uses filename extensions to determine how to load files.
The keys of entries in the `loaders` table are the file extensions.
These map to functions that take in a filename and return a loaded asset.
In the above example, we run the function `love.graphics.newImage` on any filenames that end in `.jpg`.

Here is a list of default loaders used:

| Extension | Loader                    |
| --------- | ------------------------- |
| lua       | `love.filesystem.load`    |
| png       | `love.graphics.newImage`  |
| jpg       | `love.graphics.newImage`  |
| dds       | `love.graphics.newImage`  |
| ogv       | `love.graphics.newVideo`  |
| glsl      | `love.graphics.newShader` |
| mp3       | `love.audio.newSource`    |
| ogg       | `love.audio.newSource`    |
| wav       | `love.audio.newSource`    |
| txt       | `love.filesystem.read`    |

The loader for `.ttf` files is special. Instead of directly returning an asset, this loader returns a function that accepts a size for the font and returns a new font with the specified size.

To have cargo ignore files with a certain extension, specify `false` as the loader.

### Processors

Sometimes, it can be helpful to do some extra processing on assets after they are loaded.
This extra work can be configured by the `processors` option.
The keys are Lua patterns that match filenames, and the values are functions that get passed the asset and the filename of the asset.
In the above example, we set the scaling filter on all assets in the `images/` directory, regardless of extension.

License
---

MIT, see [`LICENSE`](LICENSE) for details.
