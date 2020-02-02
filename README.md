Cargo
===

Cargo makes it easy to manage assets in a Love2D project by exposing project directories as Lua tables.
This means you can access your files from a table automatically without needing to load them first.
Assets are lazily loaded, cached, and can be nested arbitrarily.

You can also manually preload sets of assets at a specific time to avoid loading hitches.

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

After something has been loaded, you can set it to `nil` to clear it from the cargo table.  Note
that it will only be garbage collected if nothing else references it.

You can also preload all of the assets in a cargo table by calling it (or any of its children) as a function:

```lua
assets = cargo.init('media')()     -- Load everything in 'media'
assets = cargo.init('media')(true) -- Load everything in 'media', recursively

assets.sound.background()          -- Preload all of the background music
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
| flac      | `love.audio.newSource`    |
| txt       | `love.filesystem.read`    |
| fnt       | `love.graphics.newFont`   |

The loader for `.ttf` and `.otf` files is special. Instead of directly returning an asset, this loader returns a function that accepts a size for the font and returns a new font with the specified size.

The loader for `.fnt` files requires the image file path to be set in the file as it won't be passed to [love.graphics.newFont](https://love2d.org/wiki/love.graphics.newFont#Function_3).

To have cargo ignore files with a certain extension, specify `false` as the loader.

### Processors

Sometimes, it can be helpful to do some extra processing on assets after they are loaded.
This extra work can be configured by the `processors` option.
The keys are Lua patterns that match filenames, and the values are functions that get passed the asset and the filename of the asset.
In the above example, we set the scaling filter on all assets in the `images/` directory, regardless of extension.

License
---

MIT, see [`LICENSE`](LICENSE) for details.
