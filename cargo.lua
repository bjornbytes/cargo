-- cargo v0.1.1
-- https://github.com/bjornbytes/cargo
-- MIT License

local cargo = {}

local function merge(target, source, ...)
  if not target or not source then return target end
  for k, v in pairs(source) do target[k] = v end
  return merge(target, ...)
end

local la, lf, lg = love.audio, love.filesystem, love.graphics

local function makeSound(path)
  local info = lf.getInfo(path, 'file')
  return la.newSource(path, (info and info.size and info.size < 5e5) and 'static' or 'stream')
end

local function makeFont(path)
  return function(size)
    return lg.newFont(path, size)
  end
end

local function loadFile(path)
  return lf.load(path)()
end

cargo.loaders = {
  lua = lf and loadFile,
  png = lg and lg.newImage,
  jpg = lg and lg.newImage,
  dds = lg and lg.newImage,
  ogv = lg and lg.newVideo,
  glsl = lg and lg.newShader,
  mp3 = la and makeSound,
  ogg = la and makeSound,
  wav = la and makeSound,
  txt = lf and lf.read,
  ttf = lg and makeFont,
  otf = lg and makeFont,
  fnt = lg and lg.newFont
}

cargo.processors = {}

function cargo.init(config)
  if type(config) == 'string' then
    config = { dir = config }
  end

  local loaders = merge({}, cargo.loaders, config.loaders)
  local processors = merge({}, cargo.processors, config.processors)

  local init

  local function halp(t, k)
    local path = (t._path .. '/' .. k):gsub('^/+', '')
    local fileInfo = lf.getInfo(path, 'directory')
    if fileInfo then
      rawset(t, k, init(path))
      return t[k]
    else
      for extension, loader in pairs(loaders) do
        local file = path .. '.' .. extension
        local fileInfo = lf.getInfo(file)
        if loader and fileInfo then
          local asset = loader(file)
          rawset(t, k, asset)
          for pattern, processor in pairs(processors) do
            if file:match(pattern) then
              processor(asset, file, t)
            end
          end
          return asset
        end
      end
    end

    return rawget(t, k)
  end

  local function __call(t, recurse)
    for i, f in ipairs(love.filesystem.getDirectoryItems(t._path)) do
      local key = f:gsub('%..-$', '')
      halp(t, key)

      if recurse and love.filesystem.getInfo(t._path .. '/' .. f, 'directory') then
        t[key](recurse)
      end
    end

    return t
  end

  init = function(path)
    return setmetatable({ _path = path }, { __index = halp, __call = __call })
  end

  return init(config.dir)
end

return cargo
