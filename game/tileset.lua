local TILESET = {

    image = nil,
    tiles = {},
    tilesize = 16,

    length = 0
}

function TILESET:new(o)
	o = o or {}
	setmetatable(o, self)
    self.__index = self
	return o
end

function TILESET:SetTileset(path, s)
    print("Fetching tileset from: "..path)
    self.image = love.graphics.newImage(path)
    self.tilesize = s or self.tilesize

    local im_w, im_h = self.image:getDimensions()

    local col = im_w / s
    local row = im_h / s

    for x=0, col-1 do
        for y=0, row-1 do
            index = x + (y * col)
            q = love.graphics.newQuad(x * s, y * s, s, s, im_w, im_h)
            self.tiles[index] = q
        end
    end

    self.length = col * row
end

function TILESET:DrawTile(x,y,tile)
    love.graphics.draw(self.image, self.tiles[tile], x, y)
end

return TILESET
